#!/bin/bash

region="eu-west-3"
output="json"

#Validate templates START

./tests/validate-templates.sh

#Validate templates END

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


printf "$AWS_ACCESS_KEY\n$AWS_ACCESS_SECRET\n$region\n$output\n" | aws configure


#Push configs to S3 bucket START

baseUrl="https://$AWS_S3_BUCKET_NAME.s3.$region.amazonaws.com/"
aws s3 mb "s3://$AWS_S3_BUCKET_NAME"

##Push VPC template to S3
vpc_url="s3://$AWS_S3_BUCKET_NAME/infrastructure/vpc.yaml"
aws s3 cp "./infrastructure/vpc.yaml" "$vpc_url"
aws s3api put-object-acl --bucket "$AWS_S3_BUCKET_NAME" --key "infrastructure/vpc.yaml" --grant-read uri=http://acs.amazonaws.com/groups/global/AllUsers
##


##Push Security Group template to S3
vpc_url="s3://$AWS_S3_BUCKET_NAME/infrastructure/security-groups.yaml"
aws s3 cp "./infrastructure/security-groups.yaml" "$vpc_url"
aws s3api put-object-acl --bucket "$AWS_S3_BUCKET_NAME" --key "infrastructure/security-groups.yaml" --grant-read uri=http://acs.amazonaws.com/groups/global/AllUsers
##




#Push configs to S3 bucket END

#CloudFormation deploy START

aws cloudformation deploy \
    --template-file master.yaml \
    --stack-name $CLOUDFORMATION_STACK_NAME \
    --capabilities CAPABILITY_NAMED_IAM

#CloudFormation deploy END