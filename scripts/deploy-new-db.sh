#!/bin/bash

while [ $# -gt 0 ]; do
  case "$1" in
    --k=*)
      AWS_ACCESS_KEY="${1#*=}"
      ;;
    --s=*)
      AWS_ACCESS_SECRET="${1#*=}"
      ;;
    *)
      printf "***************************\n"
      printf "* Error: Invalid argument.*\n"
      printf "***************************\n"
      exit 1
  esac
  shift
done

AWS_S3_BUCKET_NAME="autshop"
CLOUDFORMATION_STACK_NAME="shop"


./scripts/helpers/aws_initialize.sh -k "$AWS_ACCESS_KEY" -s "$AWS_ACCESS_SECRET" -b "$AWS_S3_BUCKET_NAME"

./scripts/helpers/s3_template_upload.sh -t "database/db-instance.yaml"

aws cloudformation deploy \
    --template-file ./templates/database/db-instance.yaml \
    --stack-name "shop-db" \
    --parameter-overrides DBUsername="akos" DBPassword="Akosakos1" \
    --capabilities CAPABILITY_NAMED_IAM

