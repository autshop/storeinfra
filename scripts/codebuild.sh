#!/bin/bash

echo "Started building storefront image."

CODEBUILD_RESPONSE=$(aws codebuild start-build --project-name shop-storefront --environment-variables-override '[{"name":"TENANT_ID","value":"2"},{"name":"NEXT_PUBLIC_TENANT_NAME","value":"olcsos"},{"name":"NEXT_PUBLIC_SERVER_URL","value":"https://api.olcsos.shop.akosfi.com"}]')
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