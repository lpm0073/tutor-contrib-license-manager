License Manager plugin for Tutor
=====================================
.. image:: https://img.shields.io/badge/hack.d-Lawrence%20McDaniel-orange.svg
  :target: https://lawrencemcdaniel.com
  :alt: Hack.d Lawrence McDaniel

.. image:: https://img.shields.io/static/v1?logo=discourse&label=Forums&style=flat-square&color=ff0080&message=discuss.overhang.io
  :alt: Forums
  :target: https://discuss.openedx.org/

.. image:: https://img.shields.io/static/v1?logo=readthedocs&label=Documentation&style=flat-square&color=blue&message=docs.tutor.overhang.io
  :alt: Documentation
  :target: https://docs.tutor.overhang.io
|
.. image:: https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white
  :target: https://www.docker.com/
  :alt: Docker

.. image:: https://img.shields.io/badge/kubernetes-%23326ce5.svg?style=for-the-badge&logo=kubernetes&logoColor=white
  :target: https://kubernetes.io/
  :alt: Kubernetes
|

.. image:: https://avatars.githubusercontent.com/u/40179672
  :target: https://openedx.org/
  :alt: OPEN edX
  :width: 75px
  :align: center

.. image:: https://overhang.io/static/img/tutor-logo.svg
  :target: https://docs.tutor.overhang.io/
  :alt: Tutor logo
  :width: 75px
  :align: center

|

This is a plugin for [Tutor](https://docs.tutor.overhang.io) that integrates the [License Manager](https://github.com/openedx/license-manager/) service in an Open edX platform. For further instructions on how to setup License Manager with Open edX, check the `official License Manager documentation <https://github.com/openedx/license-manager/tree/master/docs/>`__.

Installation
------------

Linux & macOS command line
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

```bash
    pip install git+https://github.com/lpm0073/tutor-contrib-license-manager
```

Kubernetes
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This plugins is compatible with `Kubernetes integration <http://docs.tutor.overhang.io/k8s.html>`__. When deploying to a Kubernetes cluster, run instead::

```bash
    tutor k8s quickstart
```

**Github Actions**

- [Build](https://github.com/openedx-actions/tutor-plugin-build-license-manager)
- [Deploy](https://github.com/openedx-actions/tutor-enable-plugin-license-manager)

**Cookiecutter Tutor Open edX Production Devops Tools**

The Open edX License Manager service is available as a preconfigured feature flag in [Cookiecutter](https://github.com/lpm0073/cookiecutter-openedx-devops)

Configuration
------------

Required parameters
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- LICENSE_MANAGER_DOCKER_IMAGE (a URI to Dockerhub, AWS ECR, etcetera)

Optional parameters
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- LICENSE_MANAGER_HOST (default: subscriptions.{{ LMS_HOST }})
- LICENSE_MANAGER_MYSQL_DATABASE (default: license_manager)
- LICENSE_MANAGER_MYSQL_USERNAME (default: license_manager)
- LICENSE_MANAGER_OAUTH2_KEY (default: license-manager-key)
- LICENSE_MANAGER_OAUTH2_KEY_DEV (default: license-manager-key-dev)
- LICENSE_MANAGER_OAUTH2_KEY_SSO (default: license-manager-key-sso)
- LICENSE_MANAGER_OAUTH2_KEY_SSO_DEV (default: license-manager-key-sso-dev)
- LICENSE_MANAGER_MYSQL_PASSWORD (default {{ 8|random_string }})
- LICENSE_MANAGER_OAUTH2_SECRET (default: {{ 16|random_string }})
- LICENSE_MANAGER_SECRET_KEY (default: {{ 24|random_string }})
- LICENSE_MANAGER_SOCIAL_AUTH_EDX_OAUTH2_SECRET (default: {{ 16|random_string }})
- LICENSE_MANAGER_BACKEND_SERVICE_EDX_OAUTH2_SECRET (default: {{ 16|random_string }})
- LICENSE_MANAGER_OAUTH2_SECRET (default: {{ 16|random_string }})
- LICENSE_MANAGER_OAUTH2_SECRET_DEV (default: {{ 16|random_string }})
- LICENSE_MANAGER_OAUTH2_SECRET_SSO (default: {{ 16|random_string }})
- LICENSE_MANAGER_OAUTH2_SECRET_SSO_DEV (default: {{ 16|random_string }}

Usage
------------

```bash
    tutor plugins enable license_manager
```

License
------------

This software is licensed under the terms of the AGPLv3.
