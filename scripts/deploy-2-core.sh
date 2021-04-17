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

load_balancer_core_url="s3://$AWS_S3_BUCKET_NAME/templates/load-balancer-core.yaml"
aws s3 cp "./templates/load-balancer-core.yaml" "$load_balancer_core_url"
aws s3api put-object-acl --bucket "$AWS_S3_BUCKET_NAME" --key "templates/load-balancer-core.yaml" --grant-read uri=http://acs.amazonaws.com/groups/global/AllUsers


ecs_cluster_core_url="s3://$AWS_S3_BUCKET_NAME/templates/ecs-cluster-core.yaml"
aws s3 cp "./templates/ecs-cluster-core.yaml" "$ecs_cluster_core_url"
aws s3api put-object-acl --bucket "$AWS_S3_BUCKET_NAME" --key "templates/ecs-cluster-core.yaml" --grant-read uri=http://acs.amazonaws.com/groups/global/AllUsers


ecs_service_core_url="s3://$AWS_S3_BUCKET_NAME/templates/ecs-service-core-api.yaml"
aws s3 cp "./templates/ecs-service-core-api.yaml" "$ecs_service_core_url"
aws s3api put-object-acl --bucket "$AWS_S3_BUCKET_NAME" --key "templates/ecs-service-core-api.yaml" --grant-read uri=http://acs.amazonaws.com/groups/global/AllUsers


aws cloudformation describe-stacks --no-paginate --query "Stacks[].Outputs[]" --output json >> ./temp/1.json

ko=$(jq '.[] | select(.OutputKey == "VPC").OutputValue' ./temp/1.json)
echo $ko

rm -rf ./temp/1.json


aws cloudformation deploy \
    --template-file ./deployments/2-core.yaml \
    --stack-name $CLOUDFORMATION_STACK_NAME \
    --capabilities CAPABILITY_NAMED_IAM