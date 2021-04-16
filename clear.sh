#!/bin/bash

region="eu-west-3"
output="json"

while getopts ":k:s:c:" opt; do
  case $opt in
    k) AWS_ACCESS_KEY="$OPTARG"
    ;;
    s) AWS_ACCESS_SECRET="$OPTARG"
    ;;
    c) CLOUDFORMATION_STACK_NAME="$OPTARG"
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    ;;
  esac
done


printf "$AWS_ACCESS_KEY\n$AWS_ACCESS_SECRET\n$region\n$output\n" | aws configure

#CloudFormation clean START

aws cloudformation delete-stack --stack-name $CLOUDFORMATION_STACK_NAME

#CloudFormation clean END