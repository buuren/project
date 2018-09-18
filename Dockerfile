FROM centos/python-36-centos7

ENV PATH "/usr/local/bin:${PATH}"

ARG WORKDIR='/home/python/app'
ARG HOME='/home/python'
ARG USER='python'

USER root

RUN groupadd docker
RUN useradd -d ${HOME} -G docker -ms /usr/bin/bash ${USER}

USER ${USER}

# APPLICATION
COPY . ${WORKDIR}
WORKDIR ${WORKDIR}

#Clean all crap
RUN make clean-all
RUN pip install pipenv
RUN make

ENTRYPOINT make run
