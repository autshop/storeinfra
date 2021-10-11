#!/bin/bash

while getopts ":t:" opt; do
  case $opt in
    t) TEMPLATE="$OPTARG"
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    ;;
  esac
done

AWS_S3_BUCKET_NAME="autshop"

template_path="s3://$AWS_S3_BUCKET_NAME/$TEMPLATE"
aws s3 cp "./$TEMPLATE" "$template_path"
aws s3api put-object-acl --bucket "$AWS_S3_BUCKET_NAME" --key "$TEMPLATE" --grant-read uri=http://acs.amazonaws.com/groups/global/AllUsers
