#!/bin/bash

source ./scripts/helpers/variables.sh
source ./scripts/helpers/cf_outputs_get.sh

rm -rf ./temp/outputs.json

while [ $# -gt 0 ]; do
  case "$1" in
    --k=*)
      AWS_ACCESS_KEY="${1#*=}"
      ;;
    --s=*)
      AWS_ACCESS_SECRET="${1#*=}"
      ;;
    --i=*)
      TENANT_ID="${1#*=}"
      ;;
    --n=*)
      TENANT_NAME="${1#*=}"
      ;;
    --p=*)
      PRIORITY="${1#*=}"
      ;;
    *)
      printf "***************************\n"
      printf "* Error: Invalid argument.*\n"
      printf "***************************\n"
      exit 1
  esac
  shift
done

./scripts/helpers/aws_initialize.sh -k "$AWS_ACCESS_KEY" -s "$AWS_ACCESS_SECRET" -b "$AWS_S3_BUCKET_NAME"

./scripts/helpers/upload_deployments.sh --k="$AWS_ACCESS_KEY" --s="$AWS_ACCESS_SECRET"

#!enviroment variables only for test purposes!
aws cloudformation deploy \
    --template-file ./deployments/new-store.yaml \
    --stack-name "$CLOUDFORMATION_STACK_NAME-store-$TENANT_ID" \
    --parameter-overrides TenantName="$TENANT_NAME" HostedZoneId="$HostedZoneId" \
    --capabilities CAPABILITY_NAMED_IAM

#aws s3 sync "s3://autshop/tenant-$TENANT_ID" "s3://admin.$TENANT_NAME.shop.akosfi.com" --delete