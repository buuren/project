# Bootstrap python project: template

### Structure
```
├── CHANGELOG.md            -- Changelog
├── CONTRIBUTING.md         -- Info how to setup local dev environment
├── .coveragerc             -- Used by nose-cov
├── .gitignore              -- Contains python specific tmp files to ignore in git. Source: https://github.com/github/gitignore/blob/master/Python.gitignore
├── LICENSE                 -- Info about licensing
├── Makefile                -- Loaded automatically by make command. Contains whole logic
├── MANIFEST.in             -- Used by python for code distribution. Source: https://docs.python.org/2/distutils/sourcedist.html#the-manifest-in-template
├── Pipfile                 -- Configurion for pipenv. Contains project requirements: python version, dependencies. Docs http://pipenv.readthedocs.io/en/latest/
├── TOREPLACE               -- Directory for project code
│   ├── __init__.py         -- Info for setup.py
│   └── TOREPLACE.py        -- Main module of the project (entrypoint)
├── .pycodestyle.ini        -- Configuration for pycodestyle. Docs: https://pycodestyle.readthedocs.io/en/latest/
├── .pydocstyle.ini         -- Configuration file pydocstyle. Docs: https://pydocstyle.readthedocs.io/en/latest/
├── .pylint.ini             -- Configuration for pylint. Docs: https://pylint.readthedocs.io/en/latest/
├── README.md               -- Documentation, usage
├── setup.py                -- Setup file for packaging, distribution to PyPI. Prepares egg-info file (target: all/install)
├── scent.py                -- Used by sniffer. Run unit/integration tests automatically on file changet (target: ci)
└── tests                   -- Directory for integration tests. Used by nose (target: test-integration)
└── .verchew.ini            -- Configuration file for additional system dependencies (binaries). Used by verchew (target: doctor)
```


### Usage

* Clone repository
* Remove git data:
    * ```rm -rf .git```
* Find and replace all files with string TOREPLACE with your Project Name
    * ```grep -rl TOREPLACE .```
    * ```Rename project directory TOREPLACE```
    * Change python version in Pipfile
* Run `make all` to prepare dev environment:
    * Creates virtual environment **.venv/** under project under
    * Installs system dependencies (pipenv, verchew)
    * Installs project dependencies
    * Locks dependencies in Pipfile.lock
* Run `make doctor` again to verify additional system dependencies
* Run `make help` for more make examples
* Replace the contents of this README with your project README description 
