#!/bin/bash

source ./scripts/helpers/variables.sh

while [ $# -gt 0 ]; do
  case "$1" in
    --k=*)
      AWS_ACCESS_KEY="${1#*=}"
      ;;
    --s=*)
      AWS_ACCESS_SECRET="${1#*=}"
      ;;
    *)
      printf "***************************\n"
      printf "* Error: Invalid argument.*\n"
      printf "***************************\n"
      exit 1
  esac
  shift
done

aws s3 sync ./deployments s3://autshop/deployments --delete
aws s3 sync ./templates s3://autshop/templates --delete



