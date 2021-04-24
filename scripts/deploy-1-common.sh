#!/bin/bash


while getopts ":k:s:b:c:" opt; do
  case $opt in
    k) AWS_ACCESS_KEY="$OPTARG"
    ;;
    s) AWS_ACCESS_SECRET="$OPTARG"
    ;;
    b) AWS_S3_BUCKET_NAME="$OPTARG"
    ;;
    c) CLOUDFORMATION_STACK_NAME="$OPTARG"
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    ;;
  esac
done


./scripts/helpers/aws_initialize.sh -k "$AWS_ACCESS_KEY" -s "$AWS_ACCESS_SECRET" -b "$AWS_S3_BUCKET_NAME"

./scripts/helpers/s3_template_upload.sh -t "vpc/vpc.yaml"

./scripts/helpers/s3_template_upload.sh -t "security-group/security-groups.yaml"


aws cloudformation deploy \
    --template-file ./deployments/1-common.yaml \
    --stack-name "$CLOUDFORMATION_STACK_NAME" \
    --capabilities CAPABILITY_NAMED_IAM