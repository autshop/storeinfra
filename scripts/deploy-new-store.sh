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
    --a=*)
      AWS_CDN_ACCESS_KEY_ID="${1#*=}"
      ;;
    --b=*)
      AWS_CDN_SECRET_ACCESS_KEY="${1#*=}"
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

./scripts/helpers/codebuild_storefront.sh -i "$TENANT_ID" -n "$TENANT_NAME"

./scripts/helpers/codebuild_storeadmin.sh -i "$TENANT_ID" -n "$TENANT_NAME"

#!enviroment variables only for test purposes!
aws cloudformation deploy \
    --template-file ./deployments/new-store.yaml \
    --stack-name "$CLOUDFORMATION_STACK_NAME-store-$TENANT_ID" \
    --parameter-overrides VPC="$VPC" ClusterStoreAPI="$StoreAPICluster" ClusterStorefront="$StorefrontCluster" TenantId=$(expr $TENANT_ID + 0) TenantName="$TENANT_NAME" HostedZoneId="$HostedZoneId" LoadBalancerDNSStoreAPI="$LoadBalancerUrlStoreAPI" LoadBalancerDNSStorefront="$LoadBalancerUrlStorefront" CanonicalHostedZoneIDStoreAPI="$CanonicalHostedZoneIDStoreAPI" CanonicalHostedZoneIDStorefront="$CanonicalHostedZoneIDStorefront" ListenerStoreAPI="$ALBListenerStoreAPI" ListenerStorefront="$ALBListenerStorefront" Priority=$(expr $PRIORITY + 0) EnvDbUsername="ocxqepfk" EnvDbPort="5432" EnvDbPassword="z56bH-1_LFHjUdiHG-mNNuNvI47DelZf" EnvDbName="ocxqepfk" EnvDbServer="queenie.db.elephantsql.com" EnvCDNAWSAccessKeyId="$AWS_CDN_ACCESS_KEY_ID" EnvCDNAWSSecretAccessKey="$AWS_CDN_SECRET_ACCESS_KEY"\
    --capabilities CAPABILITY_NAMED_IAM

aws s3 sync "s3://autshop/tenant-$TENANT_ID" "s3://admin.$TENANT_NAME.shop.akosfi.com" --delete