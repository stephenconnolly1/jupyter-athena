#!/usr/bin/env bash

: "${AWS_DEFAULT_REGION:?Need to set AWS_DEFAULT_REGION non-empty}"
: "${AWS_SECRET_ACCESS_KEY:?Need to set AWS_SECRET_ACCESS_KEY non-empty}"
: "${AWS_ACCESS_KEY_ID:?Need to set AWS_ACCESS_KEY_ID non-empty}"

docker build -t jupyter/minimal-athena . || (echo "failed"; exit 1)

docker run --rm -it \
-e AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION} \
-e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
-e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
-e AWS_ROLE_ARN=${AWS_ROLE_ARN} \
-e AWS_MFA_SERIAL_NUMBER=${AWS_MFA_SERIAL_NUMBER} \
-e AWS_S3_KMS_KEY=${AWS_S3_KMS_KEY} \
-e AWS_ATHENA_S3_OUTPUT=${AWS_ATHENA_S3_OUTPUT} \
-p 8888:8888 \
-v `pwd`:/home/jovyan/work \
jupyter/minimal-athena jupyter notebook --NotebookApp.token=''
