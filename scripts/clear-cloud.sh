#!/bin/bash

rm -rf ./temp/outputs.json

source ./scripts/helpers/variables.sh

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

#THIS REMOVES ALL BUCKET!
aws s3 ls | cut -d" " -f 3 | xargs -I{} aws s3 rb s3://{} --force

aws cloudformation delete-stack --stack-name "$CLOUDFORMATION_STACK_NAME-storefront"
aws cloudformation delete-stack --stack-name "$CLOUDFORMATION_STACK_NAME-store-api"
aws cloudformation delete-stack --stack-name "$CLOUDFORMATION_STACK_NAME-core"
aws cloudformation delete-stack --stack-name "$CLOUDFORMATION_STACK_NAME-secrets"
aws cloudformation delete-stack --stack-name "$CLOUDFORMATION_STACK_NAME"
