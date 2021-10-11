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
    --c=*)
      CLOUDFORMATION_STACK_NAME="${1#*=}"
      ;;
    --u=*)
      DOCKERHUB_USERNAME="${1#*=}"
      ;;
    --p=*)
      DOCKERHUB_PASSWORD="${1#*=}"
      ;;
     --t=*)
      GITHUB_ACCESS_TOKEN="${1#*=}"
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

./scripts/helpers/s3_template_upload.sh -t "templates/vpc/vpc.yaml"

./scripts/helpers/s3_template_upload.sh -t "templates/security-group/security-groups.yaml"

./scripts/helpers/s3_template_upload.sh -t "templates/codebuild/codebuild-project-storefront.yaml"

aws cloudformation deploy \
    --template-file ./deployments/1-common.yaml \
    --stack-name "$CLOUDFORMATION_STACK_NAME" \
    --parameter-overrides DockerHubUsername="$DOCKERHUB_USERNAME" DockerHubPassword="$DOCKERHUB_PASSWORD" GithubAccessToken="$GITHUB_ACCESS_TOKEN" \
    --capabilities CAPABILITY_NAMED_IAM