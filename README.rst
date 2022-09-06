Open edX License Manager plugin for Tutor
=========================================
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

This is a plugin for `Tutor <https://docs.tutor.overhang.io>`__ that integrates the `License Manager <https://github.com/openedx/license-manager>`__ service in an Open edX platform.
License Manager provides supplmental e-commerce service such as monthly subscription payment options. For further instructions on how to setup License Manager with Open edX, check the `official License Manager documentation <https://github.com/openedx/license-manager/tree/master/docs/>`__.

This plugin does the following:

- License Manager software installation
- 1-click style Docker container build and push capability, including setup of Python virtual environment and static asset collection
- automated MySQL integration, including creation and migration of the database itself, mysql service account and any permissions
- automated oauth setup using the LMS as the oauth provider
- fully automated Kubernetes deployment
- TO DO: add syncronization of MySQL user accounts
- TO DO: add creation of an admin account

Getting Started
---------------
Note this `Getting Started <https://github.com/openedx/license-manager/blob/master/docs/getting_started.rst>`__ guide from the License Manager repo.
Also note that there's a helper script in the root of this repo, `tutor-build.sh <./tutor-build.sh>`__ that you can use as a guide for basic operations.

Installation
------------

This plugin requires tutor>=14.0.5, the `E-commerce plugin <https://github.com/overhangio/tutor-ecommerce>`__ which itself requires the `Discovery plugin <https://github.com/overhangio/tutor-discovery>`__, and the `MFE plugin <https://github.com/overhangio/tutor-mfe>`__.
If you have installed Tutor by downloading the pre-compiled binary, then both the Discovery and MFE plugins should be automatically installed. You can confirm by running:

.. code-block:: shell

    tutor plugins list

Linux & macOS command line
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: shell

    # install this repo to your Python virtual environment
    pip install git+https://github.com/lpm0073/tutor-contrib-license-manager

    # enable the plugin
    tutor plugins enable license_manager

    # build a Docker container
    tutor images build license_manager

    # configure this plugin
    tutor config save --set LICENSE_MANAGER_DOCKER_IMAGE="https://*******.dkr.ecr.us-east-2.amazonaws.com/license_manager:latest"  \
                      --set LICENSE_MANAGER_MYSQL_DATABASE="schoolofrock-lm"  \
                      --set LICENSE_MANAGER_MYSQL_PASSWOR="str0ng-@s-@n-0x"  \
                      --set LICENSE_MANAGER_MYSQL_USERNAME="lm-admin"


Kubernetes
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This plugins is compatible with `Kubernetes integration <http://docs.tutor.overhang.io/k8s.html>`__. When deploying to a Kubernetes cluster, run instead:

.. code-block:: shell

    tutor k8s quickstart


Github Actions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~


The following actions, available in the Github Actions Marketplace, offer seamless integration with Kubernetes platforms created with `Cookiecutter Tutor Open edX Production Devops Tools <https://github.com/lpm0073/cookiecutter-openedx-devops>`__

- `Build <https://github.com/marketplace/actions/open-edx-tutor-k8s-build-license-manager-plugin>`__: automated Docker container build and upload to AWS Elastic Container Registry
- `Deploy <https://github.com/marketplace/actions/open-edx-tutor-k8s-enable-license-manager-plugin>`__: automated deployment to AWS Elastic Kubernetes Service


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

License
------------

This software is licensed under the terms of the AGPLv3.
