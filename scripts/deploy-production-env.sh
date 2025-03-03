#!/usr/bin/env sh

# Source the .env.production file
set -a
. ../.env.production
set +a

# check for or create a kubernetes cluster for this application
if ! doctl kubernetes cluster list | grep "$CLUSTER_NAME"; then
    echo "Creating a kubernetes cluster..."
    doctl kubernetes cluster create $CLUSTER_NAME --region nyc1 --version 1.32.1-do.0 --maintenance-window saturday=02:00 --node-pool "name=$APP_NAME-pool;size=s-2vcpu-2gb;count=1;tag=web;auto-scale=true;min-nodes=1;max-nodes=3" --update-kubeconfig --ha=true --auto-upgrade=true --wait
else
    echo "$CLUSTER_NAME cluster already exists."
fi

# set context to the cluster
export KUBE_CONTEXT=$(kubectl config get-contexts --no-headers=true --output=name | grep "$CLUSTER_NAME")
kubectl config use-context $KUBE_CONTEXT

# set up metrics-server for horizontal pod autoscaling
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/high-availability-1.21+.yaml

# add or update environment variables from .env.production to the cluster as a secret
kubectl create secret generic production-env-vars --from-env-file=../.env.production --dry-run=client -o yaml | kubectl apply -f - 

# deploy the app
kubectl apply -f ../resources/production-env.yaml

# wait for the deployment to be ready
kubectl rollout status deployment/test-arch --timeout=15m
