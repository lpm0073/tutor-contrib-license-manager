#!/bin/bash
#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com
#
# date:       aug-2022
#
# usage:      i use this during development. This is intended to run from
#             inside your Cookiecutter openedx_devops Bastion server,
#             or any Ubuntu environment with tutor, docker ce, aws cli, and jq.
#
#             Build and upload the Docker container to AWS ECR.
#------------------------------------------------------------------------------
echo "using aws cli key/secret in ~/aws/credentials"
echo "using docker authentication token in ~/.docker/config.json"

AWS_REGION="us-east-2"
AWS_ACCOUNT_NUMBER=$(aws ecr describe-registry | jq -r '.registryId')
AWS_ECR_REGISTRY="${AWS_ACCOUNT_NUMBER}.dkr.ecr.${AWS_REGION}.amazonaws.com"

# Request an AWS ECR login authentication token for docker.
# this is stored locally in /home/ubuntu/.docker/config.json and lasts for 12 hours.
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ECR_REGISTRY

LMS_HOST="web.stepwise.ai"
HOST="subscriptions.${LMS_HOST}"

PLUGIN_NAME="license_manager"
PLUGIN_REPO="https://github.com/lpm0073/tutor-contrib-license-manager"

# Plugin installation
# ----------------------------------------------
pip uninstall tutor-contrib-license-manager -y
pip install git+${PLUGIN_REPO}
tutor plugins enable ${PLUGIN_NAME}

# Plugin configuration
# -----------------------------------------------------------------------------
# retrieve mysql-license-manager secret from k8s, decode,
# parse and push variables to the terminal. examples:
#
#   TUTOR_LICENSE_MANAGER_MYSQL_DATABASE=webstepwisemathai_prod_lm
#   TUTOR_LICENSE_MANAGER_MYSQL_PASSWORD=zQi----secret------T5Q
#   TUTOR_LICENSE_MANAGER_MYSQL_USERNAME=webstepwisemathai_prod_lm
#   TUTOR_MYSQL_HOST=stepwisemath-global-live.cqkw93ffci2g.us-east-2.rds.amazonaws.com
#   TUTOR_MYSQL_PORT=3306
# -----------------------------------------------------------------------------
$(kubectl get secret mysql-license-manager -n stepwisemath-global-prod  -o json | jq  '.data | map_values(@base64d)' |   jq -r 'keys[] as $k | "export TUTOR_\($k|ascii_upcase)=\(.[$k])"')

# -----------------------------------------------------------------------------
# retrieve license-manager-oauth secret from k8s, decode,
# parse and push variables to the terminal. examples:
#
#   TUTOR_LICENSE_MANAGER_OAUTH2_KEY=license-manager-key
#   TUTOR_LICENSE_MANAGER_OAUTH2_KEY_DEV=license-manager-key-dev
#   TUTOR_LICENSE_MANAGER_OAUTH2_KEY_SSO=license-manager-key-sso
#   TUTOR_LICENSE_MANAGER_OAUTH2_KEY_SSO_DEV=license-manager-key-sso-dev
#   TUTOR_LICENSE_MANAGER_OAUTH2_SECRET=Gfu----secret------FYP
#   TUTOR_LICENSE_MANAGER_OAUTH2_SECRET_DEV=jpH----secret------T5Q
#   TUTOR_LICENSE_MANAGER_OAUTH2_SECRET_SSO=zmh-----secret-----6sR
#   TUTOR_LICENSE_MANAGER_OAUTH2_SECRET_SSO_DEV=IvQ----secret------v7o
# -----------------------------------------------------------------------------
$(kubectl get secret license-manager-oauth -n stepwisemath-global-prod  -o json | jq  '.data | map_values(@base64d)' |   jq -r 'keys[] as $k | "export TUTOR_\($k|ascii_upcase)=\(.[$k])"')

tutor config save --set "LICENSE_MANAGER_LMS_HOST=${LMS_HOST}" \
                  --set "LICENSE_MANAGER_HOST=${HOST}" \

# Docker build / AWS ECR upload
# ----------------------------------------------
TUTOR_VERSION=$(tutor --version | cut -f3 -d' ')
AWS_ECR_REPOSITORY=${PLUGIN_NAME}
REPOSITORY_TAG="${TUTOR_VERSION}-$(date +%Y%m%d%H%M)"
AWS_ECR_REPOSITORY_URL="${AWS_ECR_REGISTRY}/${AWS_ECR_REPOSITORY}"

DOCKER_IMAGE="${AWS_ECR_REPOSITORY_URL}:${REPOSITORY_TAG}"
DOCKER_IMAGE_LATEST="${AWS_ECR_REPOSITORY_URL}:latest"

tutor config save --set "LICENSE_MANAGER_DOCKER_IMAGE=${DOCKER_IMAGE}"

tutor images build ${PLUGIN_NAME}
tutor images push ${PLUGIN_NAME}        # FIX NOTE: Error: Image 'license_manager' could not be found

docker tag ${DOCKER_IMAGE} ${DOCKER_IMAGE_LATEST}
docker push ${DOCKER_IMAGE_LATEST}
