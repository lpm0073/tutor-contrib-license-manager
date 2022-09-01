FROM docker.io/ubuntu:20.04

RUN apt update && \
  apt install -y curl git-core language-pack-en libmysqlclient-dev libssl-dev python3 python3-pip python3-venv


ARG APP_USER_ID=1000
RUN useradd --home-dir /openedx --create-home --shell /bin/bash --uid ${APP_USER_ID} app
USER ${APP_USER_ID}

# Create python venv
RUN python3 -m venv /openedx/venv/
ENV PATH "/openedx/venv/bin:$PATH"
RUN pip install setuptools==62.1.0 pip==22.0.4 wheel==0.37.1

ENV DJANGO_SETTINGS_MODULE license_manager.settings.production

# Now install license-manager
# mcdaniel additions
# basing this on: https://github.com/overhangio/tutor-license_manager/blob/master/tutorlicense_manager/templates/license_manager/build/license_manager/Dockerfile#L21
ARG LICENSE_REPOSITORY_REPOSITORY=https://github.com/edx/license_manager.git
ARG LICENSE_MANAGER_VERSION={{ OPENEDX_COMMON_VERSION }}
RUN mkdir -p /openedx/license_manager && \
    git clone $LICENSE_REPOSITORY_REPOSITORY --branch $LICENSE_MANAGER_VERSION --depth 1 /openedx/license_manager
WORKDIR /openedx/license_manager

# Copy the requirements explicitly even though we copy everything below
# this prevents the image cache from busting unless the dependencies have changed.
COPY requirements/production.txt /openedx/license_manager/requirements/production.txt
COPY requirements/pip.txt /openedx/license_manager/requirements/pip.txt

# Dependencies are installed as root so they cannot be modified by the application user.
RUN pip install -r requirements/pip.txt
RUN pip install -r requirements/production.txt

RUN pip install uwsgi==2.0.20

# Install private requirements
# mcdaniel: based on https://github.com/overhangio/tutor-license_manager/blob/master/tutorlicense_manager/templates/license_manager/build/license_manager/Dockerfile#L41
COPY --chown=app:app ./requirements/ /openedx/requirements
RUN cd /openedx/requirements/ \
  && touch ./private.txt \
  && pip install -r ./private.txt

#{% for extra_requirement in LICENSE_MANAGER_EXTRA_PIP_REQUIREMENTS %}RUN pip install {{ extra_requirement }}
#{% endfor %}


# Collect static assets (aka: "make static")
RUN python3 manage.py collectstatic --noinput

# Setup minimal yml config file, which is required by production settings
RUN echo "{}" > /openedx/config.yml
ENV LICENSE_MANAGER_CFG /openedx/config.yml

EXPOSE 8003
CMD uwsgi \
    --static-map /static=/openedx/license_manager/assets \
    --static-map /media=/openedx/license_manager/media \
    --http 0.0.0.0:8003 \
    --thunder-lock \
    --single-interpreter \
    --enable-threads \
    --processes=2 \
    --buffer-size=8192 \
    --wsgi-file license_manager/wsgi.py
