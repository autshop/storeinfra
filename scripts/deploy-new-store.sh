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

AWS_S3_BUCKET_NAME="autshop"
CLOUDFORMATION_STACK_NAME="shop"


./scripts/helpers/aws_initialize.sh -k "$AWS_ACCESS_KEY" -s "$AWS_ACCESS_SECRET" -b "$AWS_S3_BUCKET_NAME"

./scripts/helpers/s3_template_upload.sh -t "service/ecs-service-store-api.yaml"

./scripts/helpers/s3_template_upload.sh -t "hosted-zone/hosted-zone-record-store-api.yaml"

./scripts/helpers/s3_template_upload.sh -t "service/ecs-service-storefront.yaml"

./scripts/helpers/s3_template_upload.sh -t "hosted-zone/hosted-zone-record-storefront.yaml"

./scripts/helpers/cf_outputs_save.sh

VPC=$(cf_outputs_get VPC)
ALBListenerStoreAPI=$(cf_outputs_get ALBListenerStoreAPI)
StoreAPICluster=$(cf_outputs_get StoreAPICluster)
LoadBalancerUrlStoreAPI=$(cf_outputs_get LoadBalancerUrlStoreAPI)
CanonicalHostedZoneIDStoreAPI=$(cf_outputs_get CanonicalHostedZoneIDStoreAPI)
ALBListenerStorefront=$(cf_outputs_get ALBListenerStorefront)
StorefrontCluster=$(cf_outputs_get StorefrontCluster)
LoadBalancerUrlStorefront=$(cf_outputs_get LoadBalancerUrlStorefront)
CanonicalHostedZoneIDStorefront=$(cf_outputs_get CanonicalHostedZoneIDStorefront)

./scripts/helpers/codebuild.sh -i "$TENANT_ID" -n "$TENANT_NAME"


#TODO HOSTED ZONE ID BELOW
aws cloudformation deploy \
    --template-file ./deployments/new-store.yaml \
    --stack-name "$CLOUDFORMATION_STACK_NAME-store-$TENANT_ID" \
    --parameter-overrides VPC="$VPC" ClusterStoreAPI="$StoreAPICluster" ClusterStorefront="$StorefrontCluster" TenantId=$(expr $TENANT_ID + 0) TenantName="$TENANT_NAME" HostedZoneId="Z039440539RO5LOP54PP9" LoadBalancerDNSStoreAPI="$LoadBalancerUrlStoreAPI" LoadBalancerDNSStorefront="$LoadBalancerUrlStorefront" CanonicalHostedZoneIDStoreAPI="$CanonicalHostedZoneIDStoreAPI" CanonicalHostedZoneIDStorefront="$CanonicalHostedZoneIDStorefront" ListenerStoreAPI="$ALBListenerStoreAPI" ListenerStorefront="$ALBListenerStorefront" Priority=$(expr $PRIORITY + 0)\
    --capabilities CAPABILITY_NAMED_IAM

