#!/bin/bash

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
    *)
      printf "***************************\n"
      printf "* Error: Invalid argument.*\n"
      printf "***************************\n"
      exit 1
  esac
  shift
done


./scripts/helpers/aws_initialize.sh -k "$AWS_ACCESS_KEY" -s "$AWS_ACCESS_SECRET" -b "$AWS_S3_BUCKET_NAME"

./scripts/helpers/s3_template_upload.sh -t "deployments/new-store.yaml"


