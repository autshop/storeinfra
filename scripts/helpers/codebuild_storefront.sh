#!/bin/bash

while getopts ":i:n:" opt; do
  case $opt in
    i) TENANT_ID="$OPTARG"
    ;;
    n) TENANT_NAME="$OPTARG"
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    ;;
  esac
done


echo "Started building storefront image."

JSON_STRING=$( jq -n \
                  --arg tid "$TENANT_ID" \
                  --arg tn "$TENANT_NAME" \
                  --arg s "http://api.$TENANT_NAME.shop.akosfi.com" \
                  '[{name: "TENANT_ID", value: $tid}, { name: "NEXT_PUBLIC_TENANT_NAME", value: $tn},{name: "NEXT_PUBLIC_SERVER_URL",value: $s }]' )

echo $JSON_STRING

CODEBUILD_RESPONSE=$(aws codebuild start-build --project-name shop-storefront --environment-variables-override "$JSON_STRING")
CODEBUILD_BUILD_ID=$(echo $CODEBUILD_RESPONSE | jq '.build.id' | sed -e 's/^"//' -e 's/"$//')

echo "CodeBuild build ID: $CODEBUILD_BUILD_ID"

while true
do
  echo "Checking for status."
  CURRENT_PHASE=$(aws codebuild batch-get-builds --ids $CODEBUILD_BUILD_ID | jq '.builds[0].currentPhase' | sed -e 's/^"//' -e 's/"$//')
  BUILD_STATUS=$(aws codebuild batch-get-builds --ids $CODEBUILD_BUILD_ID | jq '.builds[0].buildStatus' | sed -e 's/^"//' -e 's/"$//')

  echo "CodeBuild build phase: $CURRENT_PHASE"
  echo "CodeBuild build status: $BUILD_STATUS"

  if [ "$CURRENT_PHASE" = "COMPLETED" ] && [ "$BUILD_STATUS" = "SUCCEEDED" ]
  then
    echo "Finished building storefront image. (successful)"
    break
  elif [ "$CURRENT_PHASE" = "COMPLETED" ] && [ "$BUILD_STATUS" != "SUCCEEDED" ]
  then
    echo "Finished building storefront image. (unsuccessful)"
    break
  fi

  sleep 20
done