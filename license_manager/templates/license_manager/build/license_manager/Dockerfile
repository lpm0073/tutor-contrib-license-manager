#------------------------------------------------------------------------------
# written by:   Lawrence McDaniel
#
# date:         aug-2022
#
# usage:        build the docker image. this is based on
#               https://github.com/overhangio/tutor/blob/master/tutor/templates/build/openedx/Dockerfile
#------------------------------------------------------------------------------

###### Minimal image with base system requirements for most stages
FROM docker.io/ubuntu:20.04 as minimal
LABEL maintainer="Lawrence McDaniel <lpm0073@gmail.com>"

ENV DEBIAN_FRONTEND=noninteractive
RUN apt update && \
    apt install -y build-essential curl git language-pack-en
ENV LC_ALL en_US.UTF-8

{{ patch("license-manager-dockerfile-minimal") }}

###### Install python with pyenv in /opt/pyenv and create virtualenv in /openedx/venv
FROM minimal as python
# https://github.com/pyenv/pyenv/wiki/Common-build-problems#prerequisites
RUN apt update && \
    apt install -y libssl-dev zlib1g-dev libbz2-dev \
    libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev \
    xz-utils tk-dev libffi-dev liblzma-dev python-openssl git
ARG PYTHON_VERSION=3.8.12
ENV PYENV_ROOT /opt/pyenv
RUN git clone https://github.com/pyenv/pyenv $PYENV_ROOT --branch v2.2.2 --depth 1
RUN $PYENV_ROOT/bin/pyenv install $PYTHON_VERSION
RUN $PYENV_ROOT/versions/$PYTHON_VERSION/bin/python -m venv /openedx/venv

###### Install Dockerize to wait for mysql DB availability
FROM minimal as dockerize
# https://github.com/powerman/dockerize/releases
ARG DOCKERIZE_VERSION=v0.16.0
RUN dockerize_url="https://github.com/powerman/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-$(uname -m | sed 's@aarch@arm@')" \
    && echo "Downloading dockerize from $dockerize_url" \
    && curl --fail --location --output /usr/local/bin/dockerize $dockerize_url \
    && chmod a+x /usr/local/bin/dockerize


# Now install license-manager
# mcdaniel additions
# basing this on: https://github.com/overhangio/tutor-license_manager/blob/master/tutorlicense_manager/templates/license_manager/build/license_manager/Dockerfile#L21
FROM minimal as code
ARG LICENSE_REPOSITORY_REPOSITORY=https://github.com/edx/license-manager.git
ARG LICENSE_MANAGER_VERSION={{ OPENEDX_COMMON_VERSION }}
RUN mkdir -p /openedx/license_manager && \
    git clone $LICENSE_REPOSITORY_REPOSITORY --branch $LICENSE_MANAGER_VERSION --depth 1 /openedx/license_manager
WORKDIR /openedx/license_manager

###### Install python requirements in virtualenv
FROM python as python-requirements
ENV PATH /openedx/venv/bin:${PATH}
ENV VIRTUAL_ENV /openedx/venv/

RUN apt update && apt install -y software-properties-common libmysqlclient-dev libxmlsec1-dev libgeos-dev

# Note that this means that we need to reinstall all requirements whenever there is a
# change in license_manager, which sucks. But there is no obvious alternative, as we need
# to install some packages from license_manager.
COPY --from=code /openedx/license_manager /openedx/license_manager
WORKDIR /openedx/license_manager

# Install uwsgi
# https://pypi.org/project/uWSGI/
RUN pip install uwsgi==2.0.20

{{ patch("license-manager-dockerfile-post-python-requirements") }}

# Dependencies are installed as root so they cannot be modified by the application user.
RUN ls -lha
RUN pip install -r requirements/pip.txt
RUN pip install -r requirements/production.txt

COPY ./requirements/ /openedx/requirements
RUN cd /openedx/requirements/ \
  && touch ./private.txt \
  && pip install -r ./private.txt

###### Production image with system and python requirements
FROM minimal as production

# Install system requirements.
# Mcdaniel: many of these probably are not necessary. i copied the list from the openedx build. there's almost certainly some
# overlap but i don't know which belong and which do not.
RUN apt update && \
    apt install -y gettext gfortran graphviz graphviz-dev libffi-dev libfreetype6-dev libgeos-dev libjpeg8-dev liblapack-dev libmysqlclient-dev libpng-dev libsqlite3-dev libxmlsec1-dev lynx ntp pkg-config rdfind && \
    rm -rf /var/lib/apt/lists/*

# From then on, run as unprivileged "app" user
ARG APP_USER_ID=1000
RUN useradd --home-dir /openedx --create-home --shell /bin/bash --uid ${APP_USER_ID} app
USER ${APP_USER_ID}

COPY --from=dockerize /usr/local/bin/dockerize /usr/local/bin/dockerize
COPY --chown=app:app --from=code /openedx/license_manager /openedx/license_manager
COPY --chown=app:app --from=python /opt/pyenv /opt/pyenv
COPY --chown=app:app --from=python-requirements /openedx/venv /openedx/venv
COPY --chown=app:app --from=python-requirements /openedx/requirements /openedx/requirements

ENV PATH /openedx/venv/bin:${PATH}
ENV VIRTUAL_ENV /openedx/venv/
WORKDIR /openedx/license_manager

# Re-install local requirements, otherwise egg-info folders are missing
# RUN pip install -r requirements/edx/local.in

###### Setup minimal yml config file, which is required by tutor.production settings
RUN echo "{}" > /openedx/config.yml
ENV LICENSE_MANAGER_CFG /openedx/config.yml

{{ patch("license-manager-dockerfile-pre-assets") }}

# Collect static assets (aka: "make static")
RUN python3 ./manage.py collectstatic --noinput


ENV DJANGO_SETTINGS_MODULE license_manager.settings.tutor.production

{{ patch("license-manager-dockerfile") }}

EXPOSE 8000

###### Final image with production cmd
FROM production as final

# Run server
CMD uwsgi \
    --static-map /static=/openedx/staticfiles/ \
    --static-map /media=/openedx/media/ \
    --http 0.0.0.0:8000 \
    --thunder-lock \
    --single-interpreter \
    --enable-threads \
    --processes=${UWSGI_WORKERS:-2} \
    --buffer-size=8192 \
    --wsgi-file $SERVICE_VARIANT/wsgi.py

{{ patch("license-manager-dockerfile-final") }}
