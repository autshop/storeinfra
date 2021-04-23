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

TenantId=3
TenantName="olcsobolt3"

./scripts/_aws.sh -k "$AWS_ACCESS_KEY" -s "$AWS_ACCESS_SECRET" -b "$AWS_S3_BUCKET_NAME"

ecs_service_store_api_url="s3://$AWS_S3_BUCKET_NAME/templates/ecs-service-store-api.yaml"
aws s3 cp "./templates/ecs-service-store-api.yaml" "$ecs_service_store_api_url"
aws s3api put-object-acl --bucket "$AWS_S3_BUCKET_NAME" --key "templates/ecs-service-store-api.yaml" --grant-read uri=http://acs.amazonaws.com/groups/global/AllUsers

hosted_zone_record_store_api_url="s3://$AWS_S3_BUCKET_NAME/templates/hosted-zone-record-store-api.yaml"
aws s3 cp "./templates/hosted-zone-record-store-api.yaml" "$hosted_zone_record_store_api_url"
aws s3api put-object-acl --bucket "$AWS_S3_BUCKET_NAME" --key "templates/hosted-zone-record-store-api.yaml" --grant-read uri=http://acs.amazonaws.com/groups/global/AllUsers


aws cloudformation describe-stacks --no-paginate --query "Stacks[].Outputs[]" --output json >> ./temp/outputs.json

VPC=$(jq '.[] | select(.OutputKey == "VPC").OutputValue' ./temp/outputs.json | sed -e 's/^"//' -e 's/"$//')
ALBListenerStoreAPI=$(jq '.[] | select(.OutputKey == "ALBListenerStoreAPI").OutputValue' ./temp/outputs.json | sed -e 's/^"//' -e 's/"$//')
StoreAPICluster=$(jq '.[] | select(.OutputKey == "StoreAPICluster").OutputValue' ./temp/outputs.json | sed -e 's/^"//' -e 's/"$//')
LoadBalancerUrlStoreAPI=$(jq '.[] | select(.OutputKey == "LoadBalancerUrlStoreAPI").OutputValue' ./temp/outputs.json | sed -e 's/^"//' -e 's/"$//')
CanonicalHostedZoneIDStoreAPI=$(jq '.[] | select(.OutputKey == "CanonicalHostedZoneIDStoreAPI").OutputValue' ./temp/outputs.json | sed -e 's/^"//' -e 's/"$//')


aws cloudformation deploy \
    --template-file ./deployments/new-store.yaml \
    --stack-name "$CLOUDFORMATION_STACK_NAME-store-$TenantId" \
    --parameter-overrides VPC="$VPC" Cluster="$StoreAPICluster" Listener="$ALBListenerStoreAPI" TenantId="$TenantId" TenantName="$TenantName" HostedZoneId="Z07749613A5R8NMAOOIYD" LoadBalancerDNS="$LoadBalancerUrlStoreAPI" CanonicalHostedZoneIDStoreAPI="$CanonicalHostedZoneIDStoreAPI"\
    --capabilities CAPABILITY_NAMED_IAM

