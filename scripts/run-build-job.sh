#!/usr/bin/env sh
# create a build environment for the app
export KUBE_CONTEXT=$(kubectl config get-contexts --no-headers=true --output=name | grep $CLUSTER_NAME)
kubectl config use-context $KUBE_CONTEXT
# add .env file to the cluster
kubectl create secret generic build-env-vars --from-env-file=../.env.build --dry-run=client -o yaml | kubectl apply -f -
# create a pod to build an app image
kubectl apply -f ../resources/build-job.yaml