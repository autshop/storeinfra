#!/bin/bash

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
    --b=*)
      AWS_S3_BUCKET_NAME="${1#*=}"
      ;;
    --c=*)
      CLOUDFORMATION_STACK_NAME="${1#*=}"
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

./scripts/helpers/s3_template_upload.sh -t "load-balancer/load-balancer-storefront.yaml"

./scripts/helpers/s3_template_upload.sh -t "cluster/ecs-cluster-storefront.yaml"

./scripts/helpers/cf_outputs_save.sh

VPC=$(cf_outputs_get VPC)
PublicSubnets=$(cf_outputs_get PublicSubnets)
PrivateSubnets=$(cf_outputs_get PrivateSubnets)
ECSHostSecurityGroup=$(cf_outputs_get ECSHostSecurityGroup)
LoadBalancerSecurityGroup=$(cf_outputs_get LoadBalancerSecurityGroup)

aws cloudformation deploy \
    --template-file ./deployments/4-storefront.yaml \
    --stack-name "$CLOUDFORMATION_STACK_NAME-storefront" \
    --parameter-overrides EnvironmentName="$CLOUDFORMATION_STACK_NAME-storefront" VPC="$VPC" PublicSubnets="$PublicSubnets" PrivateSubnets="$PrivateSubnets" ECSHostSecurityGroup="$ECSHostSecurityGroup" LoadBalancerSecurityGroup="$LoadBalancerSecurityGroup" \
    --capabilities CAPABILITY_NAMED_IAM

