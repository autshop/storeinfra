#!/bin/bash

source ./scripts/helpers/variables.sh


while [ $# -gt 0 ]; do
  case "$1" in
    --u=*)
      DB_USERNAME="${1#*=}"
      ;;
    --p=*)
      DB_PASSWORD="${1#*=}"
      ;;
    --d=*)
      DB_SERVER="${1#*=}"
      ;;
    --n=*)
      DB_NAME="${1#*=}"
      ;;
    --q=*)
      DB_PORT="${1#*=}"
      ;;
    --w=*)
      PORT="${1#*=}"
      ;;
    --e=*)
      JWT_SECRET="${1#*=}"
      ;;
    --r=*)
      ELEPHANTSQL_API_KEY="${1#*=}"
      ;;
    --k=*)
      AWS_ACCESS_KEY_ID="${1#*=}"
      ;;
    --s=*)
      AWS_SECRET_ACCESS_KEY="${1#*=}"
      ;;
    *)
      printf "***************************\n"
      printf "* Error: Invalid argument.*\n"
      printf "***************************\n"
      exit 1
  esac
  shift
done

./scripts/helpers/aws_initialize.sh -k "$AWS_ACCESS_KEY_ID" -s "$AWS_SECRET_ACCESS_KEY" -b "$AWS_S3_BUCKET_NAME"
./scripts/helpers/s3_template_upload.sh -t "templates/secrets-manager/secrets-core-api.yaml"


aws cloudformation deploy \
    --template-file ./deployments/0-secrets.yaml \
    --stack-name "$CLOUDFORMATION_STACK_NAME-secrets" \
    --parameter-overrides EnvDBUsername="$DB_USERNAME" EnvDBPassword="$DB_PASSWORD" EnvDBServer="$DB_SERVER" EnvDBName="$DB_NAME" EnvDBPort="$DB_PORT" EnvPort="$PORT" EnvJWTSecret="$JWT_SECRET" EnvElephantSQLAPIKey="$ELEPHANTSQL_API_KEY" EnvAWSAccessKeyId="$AWS_ACCESS_KEY_ID" EnvAWSSecretAccessKey="$AWS_SECRET_ACCESS_KEY"\
    --capabilities CAPABILITY_NAMED_IAM