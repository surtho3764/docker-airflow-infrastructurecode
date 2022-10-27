# VERSION airflow:1.10.6
# AUTHOR: Aiken
# DESCRIPTION: Basic Airflow container
# BUILD: docker build -f ./Dockerfile ubuntu/docker-airflow:1.10.6.2 -f Dockerfile
#image name:ubuntu/docker-airflow:1.10.6.2
# source:

FROM ubuntu:18.04

# ensure local python is preferred over distribution python
ENV PATH /usr/local/bin:$PATH

# Never prompts the user for choices on installation/configuration of packages
ENV DEBIAN_FRONTEND noninteractive

#PYTHON VERSION
ENV PYTHON_VERSION 3.7

# Airflow variable
ARG AIRFLOW_VERSION=1.10.9
ARG AIRFLOW_USER_HOME=/home/airflow

ARG AIRFLOW_DEPS=""
ARG PYTHON_DEPS=""

ENV AIRFLOW_HOME=${AIRFLOW_USER_HOME}




# runtime dependencies and add locales
RUN apt-get update \
   && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        apt-utils \
   && apt-get install -y --no-install-recommends \
        ca-certificates \
        netbase \
        locales \
        curl \
        vim \
        net-tools \
        netcat \
        iputils-ping \
        mysql-client

RUN locale-gen en_US.UTF-8

# Define en_US.
ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV LC_CTYPE en_US.UTF-8
ENV LC_MESSAGES en_US.UTF-8


# Add airflow user
RUN useradd -ms /bin/bash -d ${AIRFLOW_USER_HOME} airflow


# install dependencies packages
RUN apt-get update && apt-get install -y \
        build-essential \
        zlib1g-dev \
        libncurses5-dev \
        libgdbm-dev \
        libnss3-dev \
        libssl-dev \
        libreadline-dev \
        libffi-dev \
        autoconf \
        libtool \
        pkg-config \
        python-opengl \
        python-pil \
        python-pyrex \
        python-pyside.qtopengl \
        qt4-dev-tools \
        qt4-designer \
        libqtgui4 \
        libqtcore4 \
        libqt4-xml \
        libqt4-test \
        libqt4-script \
        libqt4-network \
        libqt4-dbus \
        python-qt4 \
        python-qt4-gl \
        python-dev \
        python-pip \
        libgle3 \
        libmysqlclient-dev \
        freetds-bin


# INSTALL PYTHON3.7.6 and pip
RUN apt-get update && apt-get install -y software-properties-common \
    && add-apt-repository -y ppa:ubuntu-toolchain-r/ppa \
    && apt-get -y install python3.7 \
    && apt-get -y install python3.7-dev \
    && apt-get install -y python3-pip \
    && rm -rf /var/lib/apt/lists/*


# make some useful symlinks that are expected to exist
RUN rm /usr/bin/python3 \
    && ln -s python3.7 /usr/bin/python3


# pip3 airflow packages
RUN pip3 install --upgrade setuptools pip

# revise pip3 update pip 19.3.1 bug on ubuntu 18.04
COPY pip3 /usr/bin/pip3

RUN pip3 install --use-feature=2020-resolver cryptography \
    && pip3 install --use-feature=2020-resolver apache-airflow==${AIRFLOW_VERSION} \
    && pip3 install --use-feature=2020-resolver apache-airflow[ssh${AIRFLOW_DEPS:+,}${AIRFLOW_DEPS}]==${AIRFLOW_VERSION} \
    && pip3 install --use-feature=2020-resolver apache-airflow[postgres]==${AIRFLOW_VERSION} \
    && pip3 install --use-feature=2020-resolver apache-airflow[mysql]==${AIRFLOW_VERSION} \
    && pip3 install --use-feature=2020-resolver apache-airflow[redis]==${AIRFLOW_VERSION} \
    && pip3 install --use-feature=2020-resolver celery \
    && pip3 install --use-feature=2020-resolver redis==3.2 \
    && pip3 install --use-feature=2020-resolver celery[redis] \
    && pip3 install --use-feature=2020-resolver apache-airflow[celery]==${AIRFLOW_VERSION} \
    && pip3 install --use-feature=2020-resolver werkzeug==0.16.0 \
    && pip3 install --use-feature=2020-resolver SQLAlchemy==1.3.15

RUN chown -R airflow: ${AIRFLOW_USER_HOME}


COPY entrypoint.sh /entrypoint.sh
COPY config/airflow.cfg ${AIRFLOW_HOME}/airflow.cfg


RUN ["chmod", "+x", "/entrypoint.sh"]

EXPOSE 8080 5555 8793
USER airflow

WORKDIR ${AIRFLOW_USER_HOME}

ENTRYPOINT ["/entrypoint.sh"]
# set default arg for entrypoint
CMD ["webserver"]


