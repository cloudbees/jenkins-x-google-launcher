#!/bin/bash


set -eox pipefail


/bin/print_config.py --values_mode raw --key KEY


#TODO - extract parameters
#CLUSTER="$(/bin/print_config.py --values_mode raw"

NAME="$(/bin/print_config.py \
    --xtype NAME \
    --values_mode raw)"
NAMESPACE="$(/bin/print_config.py \
    --xtype NAMESPACE \
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
kubectl config set-context warren-mp5 --user=cluster-admin --namespace=$NAMESPACE \
  && kubectl config use-context warren-mp5

# setup git
git config --global --add user.name JenkinsXBot
git config --global --add user.email jenkins-x@googlegroups.com

# Install Jenkins X into the current cluster
jx install \
-b \
--default-admin-password=admin \
--tekton \
--git-username jenkins-x-bot-test \
--git-api-token <replace-with-api-token>  \
--environment-git-owner cb-kubecd \
--provider=gke

echo "CloudBees Jenkins X is installed and running"


#jx create cluster gke -b -m n1-standard-2 --min-num-nodes=3 --max-num-nodes=5 -z europe-west1-c --skip-login  --default-admin-password=admin --project-id jx-development --tekton --git-username jenkins-x-bot-test --git-api-token <replace-token>  --environment-git-owner cb-kubecd -n marketplace-test
#
