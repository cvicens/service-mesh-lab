#!/bin/sh

. ./image-env.sh

PROJECT_NAME=lab-ossm
WORKSHOP_IMAGE=${REGISTRY}/${REGISTRY_USER_ID}/${WORKSHOP_NAME}:${WORKSHOP_VERSION}

SUBDOMAIN=$(oc get ingresses.config.openshift.io cluster -o jsonpath='{.spec.domain}')

oc create -f ./workshop/content/k8s/ccn-sso-template.yaml -n openshift

oc new-project ${PROJECT_NAME}

oc new-app -n ${PROJECT_NAME} https://raw.githubusercontent.com/openshift-homeroom/workshop-spawner/7.1.0/templates/hosted-workshop-production.json \
 --param CLUSTER_SUBDOMAIN="${SUBDOMAIN}" \
 --param SPAWNER_NAMESPACE="${PROJECT_NAME}" \
 --param WORKSHOP_NAME="${PROJECT_NAME}" \
 --param WORKSHOP_IMAGE="${WORKSHOP_IMAGE}" \
 --param OC_VERSION="${OC_VERSION}"