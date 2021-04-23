aws cloudformation describe-stacks --no-paginate --query "Stacks[].Outputs[]" --output json >> ./temp/outputs.json
