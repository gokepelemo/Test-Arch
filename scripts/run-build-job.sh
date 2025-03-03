#!/usr/bin/env sh

# Source the .env.build file
set -a
. ../.env.build
set +a

# create a kubernetes cluster with a node pool and set up environment variables
if ! doctl kubernetes cluster list | grep "$CLUSTER_NAME"; then
    echo "Creating a kubernetes cluster..."
    doctl kubernetes cluster create $CLUSTER_NAME --region nyc1 --version 1.32.1-do.0 --maintenance-window saturday=02:00 --node-pool "name=$APP_NAME-pool;size=s-2vcpu-2gb;count=1;tag=web;auto-scale=true;min-nodes=1;max-nodes=3" --update-kubeconfig --ha=true --auto-upgrade=true --wait
else
    echo "$CLUSTER_NAME cluster already exists."
fi

# create a build environment for the app
export KUBE_CONTEXT=$(kubectl config get-contexts --no-headers=true --output=name | grep "$CLUSTER_NAME")
kubectl config use-context $KUBE_CONTEXT

# add .env file to the cluster
kubectl create secret generic build-env-vars --from-env-file=../.env.build --dry-run=client -o yaml | kubectl apply -f -

# create a pod to build an app image
kubectl apply -f ../resources/build-job.yaml