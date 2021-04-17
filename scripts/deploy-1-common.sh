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


./scripts/_aws.sh -k "$AWS_ACCESS_KEY" -s "$AWS_ACCESS_SECRET" -b "$AWS_S3_BUCKET_NAME"


vpc_url="s3://$AWS_S3_BUCKET_NAME/templates/vpc.yaml"
aws s3 cp "./templates/vpc.yaml" "$vpc_url"
aws s3api put-object-acl --bucket "$AWS_S3_BUCKET_NAME" --key "templates/vpc.yaml" --grant-read uri=http://acs.amazonaws.com/groups/global/AllUsers


security_groups_url="s3://$AWS_S3_BUCKET_NAME/templates/security-groups.yaml"
aws s3 cp "./templates/security-groups.yaml" "$security_groups_url"
aws s3api put-object-acl --bucket "$AWS_S3_BUCKET_NAME" --key "templates/security-groups.yaml" --grant-read uri=http://acs.amazonaws.com/groups/global/AllUsers


aws cloudformation deploy \
    --template-file ./deployments/1-common.yaml \
    --stack-name "$CLOUDFORMATION_STACK_NAME" \
    --capabilities CAPABILITY_NAMED_IAM