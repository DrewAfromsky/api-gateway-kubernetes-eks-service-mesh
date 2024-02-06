#!/bin/bash


TEMPLATE_FILE="cloudformation-templates/main.yaml"
STACK_NAME="Drew-aws-stack"
REGION="us-east-1"

echo "Updating existing stack: $STACK_NAME"

aws cloudformation update-stack \
    --stack-name $STACK_NAME \
    --template-body file://$TEMPLATE_FILE \
    --capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND CAPABILITY_IAM \
    --region $REGION

# Wait for the stack to be created/updated
WAITER=$(aws cloudformation wait stack-update-complete --stack-name $STACK_NAME --region $REGION)
echo "Waiting for stack to be ready..."
if echo "$WAITER" | grep -q "UPDATE_ROLLBACK_COMPLETE"; then
  echo "Stack deployment failed. Check the AWS CloudFormation console event tab for more details."
  # Delete the stack after all resources have been cleaned up; then able to re-deploy
  # aws cloudformation delete-stack --stack-name $STACK_NAME --region $REGION
  exit 1
fi
echo "Stack deployment completed."