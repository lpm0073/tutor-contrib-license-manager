#!/bin/bash
#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com
#
# date:       aug-2022
#
# usage:      run this from inside your Cookiecutter openedx_devops Bastion server,
#             or any Ubuntu environment with tutor, docker ce, aws cli, jq.
#
#             Builds and uploads the Docker container to AWS ECR.
#------------------------------------------------------------------------------
PLUGIN_NAME="license_manager"
PLUGIN_REPO="https://github.com/lpm0073/tutor-contrib-license-manager"
AWS_REGION=us-east-2
AWS_ACCOUNT_NUMBER=$(aws ecr describe-registry | jq -r '.registryId')
AWS_ECR_REGISTRY="${AWS_ACCOUNT_NUMBER}.dkr.ecr.${AWS_REGION}.amazonaws.com"

# Request an AWS ECR login authentication token for docker.
# this is stored locally in /home/ubuntu/.docker/config.json and lasts for 12 hours.
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ECR_REGISTRY


# Plugin installation
# ----------------------------------------------
pip uninstall tutor-contrib-license-manager -y
pip install git+${PLUGIN_REPO}
tutor plugins enable ${PLUGIN_NAME}

#ksecret.sh mysql-license-manager stepwisemath-global-prod

# Plugin configuration
# ----------------------------------------------
LICENSE_MANAGER_MYSQL_DATABASE=webstepwisemathai_prod_lm
LICENSE_MANAGER_MYSQL_PASSWORD=FFfH6Qq4ww_9xQ6j
LICENSE_MANAGER_MYSQL_USERNAME=webstepwisemathai_prod_lm
MYSQL_HOST=stepwisemath-global-live.cqkw93ffci2g.us-east-2.rds.amazonaws.com
MYSQL_PORT=3306

LICENSE_MANAGER_OAUTH2_KEY_DEV='dev-key'
LICENSE_MANAGER_OAUTH2_SECRET='dev-secret'
LICENSE_MANAGER_OAUTH2_KEY='prod-key'
LICENSE_MANAGER_OAUTH2_SECRET='prod-secret'

tutor config save --set "LICENSE_MANAGER_LMS_HOST=web.stepwise.ai" \
                  --set "LICENSE_MANAGER_HOST=subscriptions.web.stepwise.ai" \
		          --set "LICENSE_MANAGER_MYSQL_DATABASE=${LICENSE_MANAGER_MYSQL_DATABASE}" \
                  --set "LICENSE_MANAGER_MYSQL_PASSWORD=${LICENSE_MANAGER_MYSQL_PASSWORD}" \
                  --set "LICENSE_MANAGER_MYSQL_USERNAME=${LICENSE_MANAGER_MYSQL_USERNAME}" \
                  --set "MYSQL_HOST=${MYSQL_HOST}" \
                  --set "MYSQL_PORT=${MYSQL_PORT}" \
                  --set "LICENSE_MANAGER_OAUTH2_KEY_DEV=${LICENSE_MANAGER_OAUTH2_KEY_DEV}" \
                  --set "LICENSE_MANAGER_OAUTH2_SECRET=${LICENSE_MANAGER_OAUTH2_SECRET}" \
                  --set "LICENSE_MANAGER_OAUTH2_KEY=${LICENSE_MANAGER_OAUTH2_KEY}" \
                  --set "LICENSE_MANAGER_OAUTH2_SECRET=${LICENSE_MANAGER_OAUTH2_SECRET}" \

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
tutor images push ${PLUGIN_NAME}

docker tag ${DOCKER_IMAGE} ${DOCKER_IMAGE_LATEST}
docker push ${DOCKER_IMAGE_LATEST}
