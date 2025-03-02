#!/usr/bin/env sh
# create a kubernetes cluster with a node pool and set up environment variables
if ! doctl kubernetes cluster list | grep "$CLUSTER_NAME"; then
    echo "Creating a kubernetes cluster..."
    doctl kubernetes cluster create $CLUSTER_NAME --region nyc1 --version 1.32.1-do.0 --maintenance-window saturday=02:00 --node-pool "name=$APP_NAME-pool;size=s-2vcpu-2gb;count=1;tag=web;auto-scale=true;min-nodes=1;max-nodes=3" --update-kubeconfig --ha=true --auto-upgrade=true --wait
else
    echo "$CLUSTER_NAME cluster already exists."
fi

# set up metrics-server
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/high-availability-1.21+.yaml

# add env variables to the cluster
kubectl create secret generic production-env-vars --from-env-file=../.env.production --dry-run=client -o yaml | kubectl apply -f - 
kubectl apply -f ../resources/production-env.yaml
# wait for the deployment to be ready
kubectl rollout status deployment/test-arch --timeout=15m
