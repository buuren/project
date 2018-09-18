# Project settings
PROJECT := TOREPLACE
PACKAGE := TOREPLACE
REPOSITORY := TOREPLACE/TOREPLACE
PYTHON=/usr/bin/python3.6

# Project paths
PACKAGES := $(PACKAGE) tests
CONFIG := $(wildcard *.py)
MODULES := $(wildcard $(PACKAGE)/*.py)
PIPENV := pipenv

# DOCKER
DOCKER := /usr/bin/docker
IMAGE := TOREPLACE
TAG := TOREPLACE

# Virtual environment paths
export PIPENV_SHELL_COMPAT=true
export PIPENV_VENV_IN_PROJECT=true
export PIPENV_IGNORE_VIRTUALENVS=true
ENV := .venv

# MAIN TASKS ##################################################################

SNIFFER := $(PIPENV) run sniffer

.PHONY: all
all: install

.PHONY: shell
shell: install ## Spawn shell in virtual environment
	$(PIPENV) shell

.PHONY: ci
ci: check test ## Run all tasks that determine CI status (checks + tests)

.PHONY: watch
watch: install .clean-test ## Continuously run all CI tasks when files chanage
	$(SNIFFER)

.PHONY: run
run: install
	$(PIPENV) run $(PYTHON) $(PACKAGE)/__main__.py

# SYSTEM DEPENDENCIES #########################################################

.PHONY: doctor
doctor:  ## Confirm system dependencies are available
	$(PIPENV) run verchew

# PROJECT DEPENDENCIES ########################################################

DEPENDENCIES := $(ENV)/.pipenv-$(shell md5sum Pipfile)
METADATA := $(PACKAGE).egg-info

.PHONY: install
install: $(DEPENDENCIES) $(METADATA)

$(DEPENDENCIES):
	$(PIPENV) install --python=$(PYTHON) --dev
	$(PIPENV) check
	touch $@

$(METADATA): setup.py
	$(PIPENV) run $(PYTHON) setup.py develop
	touch $@

# CHECKS: LINTER, STYLE, DOCS #################################################

PYLINT := $(PIPENV) run pylint
PYCODESTYLE := $(PIPENV) run pycodestyle
PYDOCSTYLE := $(PIPENV) run pydocstyle

.PHONY: check
check: pylint pycodestyle pydocstyle ## Run linters and static analysis

.PHONY: pylint
pylint: install
	@echo "-> Running pylint checks..."
	$(PYLINT) $(PACKAGES) $(CONFIG) --rcfile=.pylint.ini

.PHONY: pycodestyle
pycodestyle: install
	@echo "-> Running pycodestyle checks..."
	$(PYCODESTYLE) $(PACKAGES) $(CONFIG) --config=.pycodestyle.ini

.PHONY: pydocstyle
pydocstyle: install
	@echo "-> Running pydocstyle checks..."
	$(PYDOCSTYLE) $(PACKAGES) $(CONFIG)


# TESTS #######################################################################

NOSE := $(PIPENV) run nosetests
COVERAGE := $(PIPENV) run coverage
RANDOM_SEED ?= $(shell date +%s)

NOSE_OPTIONS := --with-doctest
ifndef DISABLE_COVERAGE
NOSE_OPTIONS += --with-coverage --cover-package=$(PACKAGE) --cover-html --cover-html-dir=htmlcov --cover-branches
endif

.PHONY: test
test: test-all coverage-report ## Run unit and integration tests

.PHONY: test-unit
test-unit: install .clean-test
	$(NOSE) $(PACKAGE) $(NOSE_OPTIONS)

.PHONY: test-integration
test-integration: install .clean-test
	$(NOSE) tests $(NOSE_OPTIONS)

test-all: install .clean-test
	$(NOSE) $(PACKAGES) $(NOSE_OPTIONS)

.PHONY: coverage-report
coverage-report: install .clean-test
	$(COVERAGE) run $(PACKAGE)/__main__.py
	$(COVERAGE) report -m
	$(COVERAGE) html
	@echo "Coverage report at  $(shell pwd)/htmlcov/index.html"


# BUILD #######################################################################

PYINSTALLER := $(PIPENV) run pyinstaller
PYINSTALLER_MAKESPEC := $(PIPENV) run pyi-makespec

DIST_FILES := dist/*.tar.gz dist/*.whl
EXE_FILES := dist/$(PROJECT).*

.PHONY: build
build: dist

.PHONY: dist
dist: install $(DIST_FILES)
$(DIST_FILES): $(MODULES)
	rm -f $(DIST_FILES)
	$(PIPENV) run $(PYTHON) setup.py check --restructuredtext --strict --metadata
	$(PIPENV) run $(PYTHON) setup.py sdist
	$(PIPENV) run $(PYTHON) setup.py bdist_wheel

.PHONY: exe
exe: install $(EXE_FILES)
$(EXE_FILES): $(MODULES) $(PROJECT).spec
	# For framework/shared support: https://github.com/yyuu/pyenv/wiki
	$(PYINSTALLER) $(PROJECT).spec --noconfirm --clean

.PHONY: $(PROJECT).spec ## Generate PyInstaller spec file
$(PROJECT).spec:
	$(PYINSTALLER_MAKESPEC) $(PACKAGE)/__main__.py --onefile --windowed --name=$(PROJECT)

# DOCKER ######################################################################

.PHONY: docker-build
docker-build: ## Build docker image
	$(DOCKER) build \
		--tag=$(IMAGE):$(TAG) \
		.

.PHONY: docker-push
docker-push: ## Push docker image
	$(DOCKER) push $(IMAGE):$(TAG)

.PHONY: docker-dev
docker-dev: ## Start bash in docker in container environment
	$(DOCKER) run -it -v $(shell pwd):/home/python/app --entrypoint=/bin/bash $(IMAGE):$(TAG)

.PHONY: docker-run
docker-run: ## Run app in docker container
	$(DOCKER) run $(IMAGE):$(TAG)

# RELEASE #####################################################################

TWINE := $(PIPENV) run twine

.PHONY: upload
upload: dist ## Upload the current version to PyPI
	git diff --name-only --exit-code
	$(TWINE) upload dist/*.*
	open https://pypi.python.org/pypi/$(PROJECT)

# CLEANUP #####################################################################

.PHONY: clean
clean: .clean-build .clean-test .clean-install ## Delete all generated and temporary files

.PHONY: clean-all
clean-all: clean ## Delete all generated and temporary files including virtual environment
	rm -f Pipfile.lock
	rm -rf $(ENV)

.PHONY: .clean-install
.clean-install:
	find . -name '*.pyc' -delete
	find . -name '__pycache__' -delete
	rm -rf *.egg-info

.PHONY: .clean-test
.clean-test:
	rm -rf .cache .pytest .coverage htmlcov xmlreport coverage_html_report


.PHONY: .clean-build
.clean-build:
	rm -rf *.spec dist build

# HELP ########################################################################

.PHONY: help
help: all  ## Show this message
	@which $(PIPENV) > /dev/null 2>&1 || (echo "$(PIPENV) was not found in PATH. Install $(PIPENV) or fix PATH."; exit 1)
	@echo -e "\nUsage: \n"
	@ grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\t\033[36mmake %-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help
