#!/bin/sh

#. .workshop/settings.sh
. ./image-env.sh

WORKSHOP_IMAGE=${REGISTRY}/${REGISTRY_USER_ID}/${WORKSHOP_NAME}:${WORKSHOP_VERSION}

docker tag ${WORKSHOP_NAME}:${WORKSHOP_VERSION} ${WORKSHOP_IMAGE}

docker push ${WORKSHOP_IMAGE}