CODEBUILD_RESPONSE=$(aws codebuild start-build --project-name shop-storefront --environment-variables-override '[{"name":"TENANT_ID","value":"2"},{"name":"NEXT_PUBLIC_TENANT_NAME","value":"olcsos"},{"name":"NEXT_PUBLIC_SERVER_URL","value":"https://api.olcsos.shop.akosfi.com"}]')

CODEBUILD_BUILD_ID=$(echo $CODEBUILD_RESPONSE | jq '.build.id' | sed -e 's/^"//' -e 's/"$//')

#CODEBUILD_BUILD_ID="shop-storefront:4ce34fc4-9d36-4bb1-8574-86f88426e420"
echo $CODEBUILD_BUILD_ID
#shop-storefront:4ce34fc4-9d36-4bb1-8574-86f88426e420
while true
do
  echo "loop"
  CURRENT_PHASE=$(aws codebuild batch-get-builds --ids $CODEBUILD_BUILD_ID | jq '.builds[0].currentPhase')
  BUILD_STATUS=$(aws codebuild batch-get-builds --ids $CODEBUILD_BUILD_ID | jq '.builds[0].buildStatus')
  echo $CURRENT_PHASE
  echo $BUILD_STATUS
  if [ $CURRENT_PHASE = "COMPLETED" ] && [ $BUILD_STATUS = "SUCCEEDED"]
  then
    echo "done"
    break
  fi
  sleep 20
done