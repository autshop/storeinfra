aws cloudformation describe-stacks --no-paginate --query "Stacks[].Outputs[]" --output json >> ./temp/1.json

ko=$(jq '.[] | select(.OutputKey == "VPC").OutputValue' ./temp/1.json)
echo $ko

rm -rf ./temp/1.json