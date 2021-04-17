
aws cloudformation deploy \
    --template-file ./templates/ecs-service-store-api.yaml \
    --stack-name "autstorecore-store-2" \
    --parameter-overrides VPC="vpc-0b624ec3ced868f3f" Cluster="autstorecore-cluster-core" Listener="arn:aws:elasticloadbalancing:eu-west-3:120646787562:listener/app/autstorecore-load-balancer-core/d4dd9c2f6f1c3be7/f9ef0af1ff290755"  \
    --capabilities CAPABILITY_NAMED_IAM