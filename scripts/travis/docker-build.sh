#!/usr/bin/env bash

set -xeo pipefail


root=$(dirname "$0")/../../

if [[ "$TRAVIS_PULL_REQUEST" != "false" ]]; then
  TAG=us.icr.io/nicedoc/nicedoc:${TRAVIS_PULL_REQUEST_BRANCH}

  # Install IBM Cloud Cli
  curl -sL https://ibm.biz/idt-installer | bash

  # Log in into IBM Cloud Container Service
  ibmcloud login --apikey ${IBMCLOUD_API_KEY} -g 'IBM RESEARCH PRO' -r 'us-south'
  ibmcloud cr login

  # Build docker image
  docker pull "${TAG}" || true
  docker build --cache-from ${TAG} --tag ${TAG} ${root}

  # Push image to registry
  docker push ${TAG}

  # Deploy to preview

  # Decrypt encrypted files
  openssl aes-256-cbc -k "$TRAVIS_ENCRYPT_PASSWORD" -in "${root}/scripts/helm/values.yaml.enc" -out "${root}/scripts/helm/values.yaml" -d

  # Set Kubernetes cluster
  STORE_KUBECONFIG=$(ibmcloud ks cluster-config nicedoc.io | grep KUBECONFIG)
  eval $STORE_KUBECONFIG

  # Deploy
  helm upgrade ${TRAVIS_BRANCH} ${root}/scripts/helm --install
fi

get_last_merged_branch() {
    local OWNER=`echo "${TRAVIS_REPO_SLUG}" | perl -n -e'/(.*)\// && print $1'`
    local MERGED_BRANCH=`git log --merges -n 1 | perl -n -e"/Merge pull request #\d+ from ${OWNER}\/(.*)/ && print \\$1"`
    echo ${MERGED_BRANCH}
}
