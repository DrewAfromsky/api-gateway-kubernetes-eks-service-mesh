REGION="us-east-1" # Change to your AWS region
CLUSTER_NAME="drew-eks-cluster"
FILE_PATH=$(realpath $0)

echo "File Path: $FILE_PATH"

echo "Applying Kubernetes configurations..."

# Update kubeconfig to ensure it's using the correct cluster
echo "Updating kubeconfig..."
aws eks --region $REGION update-kubeconfig --name $CLUSTER_NAME
echo "kubeconfig updated successfully."

# Project's root directory
parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
echo "Parent Path: $parent_path"

# Apply Kubernetes deployment configurations
echo "Applying deployments..."
kubectl create secret generic ecr-secret --from-file=.dockerconfigjson=$HOME/.docker/config.json --type=kubernetes.io/dockerconfigjson

kubectl apply -f $parent_path/kubernetes/deployments
echo "Deployments applied successfully."

# Apply Kubernetes service configurations
echo "Applying services..."
kubectl apply -f $parent_path/kubernetes/services
echo "Services applied successfully."

# Apply Kubernetes ingress configurations
echo "Applying ingress configurations..."
kubectl apply -f kubernetes/ingress.yaml
echo "Ingress configurations applied successfully."

echo "Kubernetes configurations update completed."