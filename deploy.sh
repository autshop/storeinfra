#!/bin/bash

region="eu-west-3"
output="json"

#Validate templates START

./tests/validate-templates.sh

#Validate templates END

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





##Push Load Balancer Store API template to S3
load_balancer_store_api="s3://$AWS_S3_BUCKET_NAME/templates/load-balancer-store-api.yaml"
aws s3 cp "./templates/load-balancer-store-api.yaml" "$load_balancer_store_api"
aws s3api put-object-acl --bucket "$AWS_S3_BUCKET_NAME" --key "templates/load-balancer-store-api.yaml" --grant-read uri=http://acs.amazonaws.com/groups/global/AllUsers
##


##Push ECS Store API Cluster template to S3
ecs_cluster_store_api_url="s3://$AWS_S3_BUCKET_NAME/templates/ecs-cluster-store-api.yaml"
aws s3 cp "./templates/ecs-cluster-store-api.yaml" "$ecs_cluster_store_api_url"
aws s3api put-object-acl --bucket "$AWS_S3_BUCKET_NAME" --key "templates/ecs-cluster-store-api.yaml" --grant-read uri=http://acs.amazonaws.com/groups/global/AllUsers
##




#Push configs to S3 bucket END

#CloudFormation deploy START

aws cloudformation deploy \
    --template-file master.yaml \
    --stack-name $CLOUDFORMATION_STACK_NAME \
    --capabilities CAPABILITY_NAMED_IAM

#CloudFormation deploy END