#!/bin/bash

REGION="us-east-1"
AWS_ACCOUNT_ID=123456789012 # Change to your AWS account ID

parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
echo "Parent Path: $parent_path"

echo "Retrieving an authentication token and authenticating Docker client to registry."
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com

services=(
  "product-service products-repository"
  "order-service orders-repository"
  "user-service users-repository"
)

for service_tuple in "${services[@]}"; do
  IFS=' ' read -r service repository <<< "$service_tuple"
  echo "Service Name: $service, Repository Name: $repository"

  service_path=$parent_path/microservices/$service
  cd $service_path
  pwd
  
  # Build the Docker image
  docker build -t $service --target $service .
  # docker buildx build --platform linux/amd64,linux/arm64 -t $service --target $service --push .
  echo "Tagging the image for $service..."
  
  # Tag the Docker image
  docker tag $service':latest' $AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$repository':latest'
  echo "Successfully tagged image for $service..."
  echo "Pushing $service to Amazon ECR..."
  docker push $AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$repository':latest'
  echo "Successfully pushed $service to Amazon ECR repository $repository."
  
  cd $parent_path
  pwd
done

echo "All Docker images pushed to Amazon ECR."