aws cloudformation describe-stacks --no-paginate --query "Stacks[].Outputs[]" --output json >> ./temp/1.json

ko=$(jq '.[] | select(.OutputKey == "VPC").OutputValue' ./temp/1.json | sed -e 's/^"//' -e 's/"$//')
echo $ko

echo $(jq '.[] | select(.OutputKey == "PublicSubnets").OutputValue' ./temp/1.json | sed -e 's/^"//' -e 's/"$//')

#rm -rf ./temp/1.json