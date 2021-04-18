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


aws cloudformation delete-stack --stack-name "shop-store-api"
aws cloudformation delete-stack --stack-name "shop-core"
aws cloudformation delete-stack --stack-name "shop"
