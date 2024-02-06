#!/bin/bash


TEMPLATE_FILE="cloudformation-templates/main.yaml"
STACK_NAME="Drew-Afromsky-AWS-Stack" # Change to your desired stack name
REGION="us-east-1" # Change to your AWS region

echo "Creating new stack: $STACK_NAME"

aws cloudformation create-stack \
    --stack-name $STACK_NAME \
    --template-body file://$TEMPLATE_FILE \
    --capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND \
    --region $REGION

# Wait for the stack to be created/updated
WAITER=$(aws cloudformation wait stack-create-complete --stack-name $STACK_NAME --region $REGION)
echo "Waiting for stack to be ready..."
if echo "$WAITER" | grep -q "ROLLBACK_COMPLETE"; then
  echo "Stack deployment failed. Check the AWS CloudFormation console event tab for more details."
  # Delete the stack after all resources have been cleaned up; then able to re-deploy
  aws cloudformation delete-stack --stack-name $STACK_NAME --region $REGION
  exit 1
fi
echo "Stack deployment completed."