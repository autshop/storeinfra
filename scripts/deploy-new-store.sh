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

TenantId=4
TenantName="olcsobolt4"

./scripts/helpers/aws_initialize.sh -k "$AWS_ACCESS_KEY" -s "$AWS_ACCESS_SECRET" -b "$AWS_S3_BUCKET_NAME"

./scripts/helpers/s3_template_upload.sh -t "ecs-service-store-api.yaml"

./scripts/helpers/s3_template_upload.sh -t "hosted-zone-record-store-api.yaml"

./scripts/helpers/cf_outputs_save.sh

VPC=$(cf_outputs_get VPC)
ALBListenerStoreAPI=$(cf_outputs_get ALBListenerStoreAPI)
StoreAPICluster=$(cf_outputs_get StoreAPICluster)
LoadBalancerUrlStoreAPI=$(cf_outputs_get LoadBalancerUrlStoreAPI)
CanonicalHostedZoneIDStoreAPI=$(cf_outputs_get CanonicalHostedZoneIDStoreAPI)


aws cloudformation deploy \
    --template-file ./deployments/new-store.yaml \
    --stack-name "$CLOUDFORMATION_STACK_NAME-store-$TenantId" \
    --parameter-overrides VPC="$VPC" Cluster="$StoreAPICluster" Listener="$ALBListenerStoreAPI" TenantId="$TenantId" TenantName="$TenantName" HostedZoneId="Z07749613A5R8NMAOOIYD" LoadBalancerDNS="$LoadBalancerUrlStoreAPI" CanonicalHostedZoneIDStoreAPI="$CanonicalHostedZoneIDStoreAPI"\
    --capabilities CAPABILITY_NAMED_IAM

