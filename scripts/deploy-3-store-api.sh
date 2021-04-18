#!/bin/bash

rm -rf ./temp/outputs.json

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

load_balancer_store_api_url="s3://$AWS_S3_BUCKET_NAME/templates/load-balancer-store-api.yaml"
aws s3 cp "./templates/load-balancer-store-api.yaml" "$load_balancer_store_api_url"
aws s3api put-object-acl --bucket "$AWS_S3_BUCKET_NAME" --key "templates/load-balancer-store-api.yaml" --grant-read uri=http://acs.amazonaws.com/groups/global/AllUsers


ecs_cluster_store_api_url="s3://$AWS_S3_BUCKET_NAME/templates/ecs-cluster-store-api.yaml"
aws s3 cp "./templates/ecs-cluster-store-api.yaml" "$ecs_cluster_store_api_url"
aws s3api put-object-acl --bucket "$AWS_S3_BUCKET_NAME" --key "templates/ecs-cluster-store-api.yaml" --grant-read uri=http://acs.amazonaws.com/groups/global/AllUsers


aws cloudformation describe-stacks --no-paginate --query "Stacks[].Outputs[]" --output json >> ./temp/outputs.json

VPC=$(jq '.[] | select(.OutputKey == "VPC").OutputValue' ./temp/outputs.json | sed -e 's/^"//' -e 's/"$//')
PublicSubnets=$(jq '.[] | select(.OutputKey == "PublicSubnets").OutputValue' ./temp/outputs.json | sed -e 's/^"//' -e 's/"$//')
PrivateSubnets=$(jq '.[] | select(.OutputKey == "PrivateSubnets").OutputValue' ./temp/outputs.json | sed -e 's/^"//' -e 's/"$//')
ECSHostSecurityGroup=$(jq '.[] | select(.OutputKey == "ECSHostSecurityGroup").OutputValue' ./temp/outputs.json | sed -e 's/^"//' -e 's/"$//')
LoadBalancerSecurityGroup=$(jq '.[] | select(.OutputKey == "LoadBalancerSecurityGroup").OutputValue' ./temp/outputs.json | sed -e 's/^"//' -e 's/"$//')

aws cloudformation deploy \
    --template-file ./deployments/3-store-api.yaml \
    --stack-name "$CLOUDFORMATION_STACK_NAME-store-api" \
    --parameter-overrides EnvironmentName="$CLOUDFORMATION_STACK_NAME-store-api" VPC="$VPC" PublicSubnets="$PublicSubnets" PrivateSubnets="$PrivateSubnets" ECSHostSecurityGroup="$ECSHostSecurityGroup" LoadBalancerSecurityGroup="$LoadBalancerSecurityGroup" \
    --capabilities CAPABILITY_NAMED_IAM

