#!/bin/bash

set -eox pipefail

/bin/print_config.py --values_mode raw --key KEY


NAME="$(/bin/print_config.py \
    --xtype NAME \
    --values_mode raw)"

NAMESPACE="$(/bin/print_config.py \
    --xtype NAMESPACE \
    --values_mode raw)"

ADMIN_PASSWORD="$(/bin/get_config.py \
    --key admin-password \
    --values_mode raw)"

CLUSTER="$(/bin/get_config.py \
    --key cluster \
    --values_mode raw)"

GIT_USERNAME="$(/bin/get_config.py \
    --key git-username \
    --values_mode raw)"

GIT_EMAIL="$(/bin/get_config.py \
    --key git-email \
    --values_mode raw)"

GIT_API_TOKEN="$(/bin/get_config.py \
    --key git-api-token \
    --values_mode raw)"

GIT_ENVIRONMENT_OWNER="$(/bin/get_config.py \
    --key git-environment-owner \
    --values_mode raw)"

export NAME
export NAMESPACE

app_uid=$(kubectl get "applications.app.k8s.io/$NAME" \
  --namespace="$NAMESPACE" \
  --output=jsonpath='{.metadata.uid}')
app_api_version=$(kubectl get "applications.app.k8s.io/$NAME" \
  --namespace="$NAMESPACE" \
  --output=jsonpath='{.apiVersion}')


# TODO remove hard coded param
# setup the kubectl context
kubectl config set-context $CLUSTER --user=cluster-admin --namespace=$NAMESPACE \
  && kubectl config use-context $CLUSTER

# setup git
git config --global --add user.name $GIT_USERNAME
git config --global --add user.email $GIT_EMAIL

# Install Jenkins X into the current cluster
jx install \
-b \
--default-admin-password=$ADMIN_PASSWORD \
--tekton \
--git-username $GIT_USERNAME \
--git-api-token $GIT_API_TOKEN \
--environment-git-owner $GIT_ENVIRONMENT_OWNER  \
--provider=gke \
--docker-registry=gcr.io

echo "CloudBees Jenkins X is installed and running"

#
#/bin/expand_config.py --values_mode raw --app_uid "$app_uid"
#
#create_manifests.sh
#
## Assign owner references for the resources.
#/bin/set_ownership.py \
#  --app_name "$NAME" \
#  --app_uid "$app_uid" \
#  --app_api_version "$app_api_version" \
#  --manifests "/data/manifest-expanded" \
#  --dest "/data/resources.yaml"
#
## Ensure assembly phase is "Pending", until successful kubectl apply.
#/bin/setassemblyphase.py \
#  --manifest "/data/resources.yaml" \
#  --status "Pending"
#
## Apply the manifest.
#kubectl apply --namespace="$NAMESPACE" --filename="/data/resources.yaml"

patch_assembly_phase.sh --status="Success"

clean_iam_resources.sh

trap - EXIT