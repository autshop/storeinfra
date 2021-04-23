#!/bin/bash

source ./scripts/helpers/cf_outputs_get.sh

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


./scripts/helpers/aws_initialize.sh -k "$AWS_ACCESS_KEY" -s "$AWS_ACCESS_SECRET" -b "$AWS_S3_BUCKET_NAME"

./scripts/helpers/s3_template_upload.sh -t "load-balancer-store-api.yaml"

./scripts/helpers/s3_template_upload.sh -t "ecs-cluster-store-api.yaml"

./scripts/helpers/cf_outputs_save.sh

VPC=$(cf_outputs_get VPC)
PublicSubnets=$(cf_outputs_get PublicSubnets)
PrivateSubnets=$(cf_outputs_get PrivateSubnets)
ECSHostSecurityGroup=$(cf_outputs_get ECSHostSecurityGroup)
LoadBalancerSecurityGroup=$(cf_outputs_get LoadBalancerSecurityGroup)

aws cloudformation deploy \
    --template-file ./deployments/3-store-api.yaml \
    --stack-name "$CLOUDFORMATION_STACK_NAME-store-api" \
    --parameter-overrides EnvironmentName="$CLOUDFORMATION_STACK_NAME-store-api" VPC="$VPC" PublicSubnets="$PublicSubnets" PrivateSubnets="$PrivateSubnets" ECSHostSecurityGroup="$ECSHostSecurityGroup" LoadBalancerSecurityGroup="$LoadBalancerSecurityGroup" \
    --capabilities CAPABILITY_NAMED_IAM

