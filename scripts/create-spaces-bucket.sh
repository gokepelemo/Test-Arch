#!/usr/bin/env sh
# Create a DigitalOcean Spaces bucket and set up environment variables
if [ -z "$BUILD_BUCKET_NAME" ]; then
    export BUILD_BUCKET_NAME="${APP_NAME}-build"
    echo "BUILD_BUCKET_NAME=${BUILD_BUCKET_NAME}" >> ../.env.build
fi
if [ -z "$BUILD_ACCESS_KEY_ID" ]; then
    echo "BUILD_ACCESS_KEY_ID is not set."
    read -p "Enter the Spaces access key: " BUILD_ACCESS_KEY_ID
    export BUILD_ACCESS_KEY_ID
    if ! grep "BUILD_ACCESS_KEY_ID" ../.env.build; then
        echo "BUILD_ACCESS_KEY_ID=${BUILD_ACCESS_KEY_ID}" >> ../.env.build
fi
if [ -z "$BUILD_SECRET_ACCESS_KEY" ]; then
    echo "BUILD_SECRET_ACCESS_KEY is not set."
    read -p "Enter the Spaces secret key: " BUILD_SECRET_ACCESS_KEY
    export BUILD_SECRET_ACCESS_KEY
    if ! grep "BUILD_SECRET_ACCESS_KEY" ../.env.build; then
        echo "BUILD_SECRET_ACCESS_KEY=${BUILD_SECRET_ACCESS_KEY}" >> ../.env.build
fi
if ! s3cmd --version > /dev/null 2>&1; then
    echo "s3cmd is not installed. Please install it first."
    exit 1
fi
if ! s3cmd ls s3://${BUILD_BUCKET_NAME} > /dev/null 2>&1; then
    echo "Creating bucket ${BUILD_BUCKET_NAME}-build..."
    s3cmd mb s3://${BUILD_BUCKET_NAME} --host=${BUILD_S3_ENDPOINT} --host-bucket=${BUILD_BUCKET_NAME}.${BUILD_S3_ENDPOINT} --signature-v2
    s3cmd setacl s3://${BUILD_BUCKET_NAME}/ --acl-private --host=${BUILD_S3_ENDPOINT} --host-bucket=${BUILD_BUCKET_NAME}.${BUILD_S3_ENDPOINT} --signature-v2
fi