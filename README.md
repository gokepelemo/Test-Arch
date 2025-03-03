### Scalable environments for deploying a highly available Node.js application on DOKS.
This is a proof-of-concept architecture for a Node.js application on DigitalOcean's Kubernetes Service. It features best practices for scalability, great performance, and cost efficiency. It makes use of other DigitalOcean products like Spaces (Object Storage) and the Container Registry.

### Requirements
- doctl version 1.122+
- kubectl version 1.32.2+
- s3cmd version 2.4.0

### Setup Guide

#### Environment Variables Required

A `env.example` file has been added to the repository for your convenience. This proof-of-concept uses `.env.build` and `.env.production` files by default to set environment variables when the included scripts are used. They need to be generated and added to `.env.build` and `.env.production` files or available through secrets on both build and production containers.
  - CLUSTER_NAME: Name the cluster that will be created.
  - APP_NAME: Name the app that will be created, used for naming app-specific components.
  - APP_ENV: Name the environment ('build' by default).
  - BUILD_BUCKET_NAME: Name of the DO Spaces bucket to use for build artifact (APP_NAME-build by default).
  - BUILD_ACCESS_KEY_ID: Access key ID of the DO Spaces bucket. Can be generated [here](https://cloud.digitalocean.com/spaces/access_keys).
  - BUILD_SECRET_ACCESS_KEY: Secret access key of the DO Spaces bucket. Can be generated [here](https://cloud.digitalocean.com/spaces/access_keys).
  - BUILD_SPACES_ENDPOINT: Endpoint of the DO Spaces bucket.
  - CODE_REPOSITORY: Full URL of the git repository where the application codebase is hosted.

#### Steps to Setup
1. Clone this repository
2. Install and auth `doctl` and `kubectl`
3. Create a Spaces bucket for application builds
4. Create Spaces access keys and run the `create-spaces-bucket.sh` script
5. Update `.env.build` and `.env.production` with the appropriate environment variables
6. Update the Kubernetes manifests in the `resources` directory
  - `spec.containers.name`: Name of the application
  - `spec.containers.image`: Image of the application (proof-of-concept is built with `node:20.15.1-alpine`)
7. If the `CODE_REPOSITORY` is already set, run the `run-build-job.sh` script
8. Run the `deploy-production-env.sh` script

### Features
- Scalability
  - Implements the DOKS cluster autoscaling feature to add new nodes to the k8s cluster if it runs out of capacity. This can be updated on any of the deployment scripts.
  - Implements horizontal pod autoscaling, scaling up reasonably when average load increases on the application pods, and scaling down when loads reduces. These can be fine-tuned in the Kubernetes manifests.
- Performance
  - Static files uploaded in the application are hosted on object storage, and a full proxy CDN can be implemented to improve network-level performance, ensuring that only API requests are processed by the application pods. 
  - Database is a managed service hosted on your choice of external database provider.
  - Config for external services are stored in .env.{build/production} environment variables through Kubernetes secrets.
- Reliability
  - Implements the DO load balancer, which is highly available by default. 
  - Application is also highly available by default, as two application pods are created on each deployment.
  - Implements the liveness and readiness probes to ensure traffic is only routed to application pods that are live.