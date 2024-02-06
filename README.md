
## Drew Afromsky
### 02/05/2024
#### Spring Field Capital - API Gateway and Service Mesh Implementation Assignment


##### Problem Statement
- Implement an API Gateway and a Service Mesh within a microservices architecture to demonstrate capabilities in managing APIs, ensuring secure and efficient communication between services, and implementing common operational patterns like rate limiting, authentication, and tracing.
##### Infrastructure/Environment Overview
###### Flask, Docker, and Kubernetes
- 3 Flask Apps (**user-service, products-service, orders-service**) for creating simple microservices
	- `POST` request to _user-service_ to make a user/login, then `GET` request to _products-service_ to list products, then `POST` request to _orders-service_ to create an order.
- 3 Docker images (one for each Flask app -- `Xxxxx-service`)
- **Kubernetes ingress configuration file**
	- Defines an Ingress resource for a Kubernetes cluster that manages external access to the services in the cluster. This configuration works with an NGINX Ingress controller.
	- When an HTTP request is received by the NGINX Ingress controller, it evaluates the request's URL against the defined rules. If a request URL matches one of the specified paths, the controller rewrites the URL (if necessary, according to the rewrite-target annotation) and forwards the request to the appropriate backend service. This enables a single entry point (the Ingress) to route traffic to multiple services within the Kubernetes cluster based on the URL path.
- **Kubernetes deployment configuration files**
	- Defines a `Deployment` object used to manage a stateless application. 
	- Instructs Kubernetes to maintain a set of Pods running a microservice (i.e. Docker container specs, number of replicas, etc.)
- **Kubernetes service configuration files**
	- Defines a `Service` object, specifically creating a load balancer type of service for each microservice. The configuration exposes the application as a network service.
	- A network path gets created for accessing the Pods running an application from outside the cluster. A `LoadBalancer` service is used to distribute incoming traffic among the Pods, providing scalability and reliability for internet-facing applications.

**NOTE:** _Aside from Flask, Docker, and Kubernetes, all the infrastructure was defined and provisioned using AWS CloudFormation._
###### Parameters
- **NodeInstanceType, NodeImageId, NodeGroupName, ClusterName**: Customizeable parameters for the EKS cluster (i.e. instance type for worker nodes, AMI ID for those nodes, the name of the node group, and the cluster name)
###### Resources
- **Amazon EKS Components**
	- **EKSCluster**: Defines the EKS cluster with a specific Kubernetes version and associated role for permissions.
	- **NodeGroup**: Specifies a group of worker nodes (EC2 instances) that will join the EKS cluster, including their type, AMI, and size.
###### Networking Components
- **DrewVPC**: Virtual private cloud (VPC) for the network isolation of the AWS resources.
- **DrewInternetGateway & GatewayAttachment**: Enables internet access for the VPC.
- **PublicSubnetOne & PublicSubnetTwo**: Two subnets that support public IP addressing for resources.
- **DrewRouteTable & PublicRoute**: Route table and routes to direct traffic from the subnets to the IgW.
- **SubnetRouteTableAssociationOne & SubnetRouteTableAssociationTwo**: Associates the subnets with the route table.
###### Security Components
- **DrewNLBSecurityGroup & EKSClusterSecurityGroup**: Security groups that act as virtual firewalls for the NLB and EKS cluster, respectively, to control inbound and outbound traffic.
###### Load Balancing Components
- **DrewNLB**: A network load balancer (NLB) to distribute traffic across the worker nodes in the EKS cluster.
- **DrewTargetGroup & DrewListener**: For managing the traffic distribution to the backend targets (worker nodes) and listening for incoming traffic on specific ports.
###### IAM Roles
- **EKSClusterRole & NodeInstanceRole**: IAM roles with policies that allow EKS and EC2 instances to make AWS API calls.
###### ECR Repositories
- **UsersRepository, OrdersRepository, ProductsRepository**: Elastic Container Registry (ECR) repositories for storing Docker images of the microservices. Kubernetes will use these to run and manage containers.
###### API Gateway Components
- **DrewAPI**: An API Gateway to create RESTful endpoints for microservices.
- **DrewAPIResourceUsers, DrewAPIResourceOrders, DrewAPIResourceProducts**: Defines the resource paths for each microservice (i.e. users, orders, and products).
- **DrewAPIMethodUsers, DrewAPIMethodOrders, DrewAPIMethodProducts**: Methods for accessing the microservices through API Gateway.
- **DrewVpcLink**: A VPC Link to allow API Gateway to communicate with resources within the VPC (i.e. the NLB)
###### AWS App Mesh Components
- **DrewServiceMesh**: Creates a service mesh to manage, control, and observe microservices traffic.
- **Virtual Nodes (UsersVirtualNode, OrdersVirtualNode, ProductsVirtualNode)**: Represents the microservices in the mesh.
- **Virtual Services (UsersVirtualService, OrdersVirtualService, ProductsVirtualService)**: Used to route traffic to the corresponding virtual nodes.
###### Deployment and Operation
- **DrewDeployment & DrewApiStage**: Deploys the API configuration and sets up a stage (i.e. prod) for the environment.
###### Summary
- The template integrates various AWS services to support a scalable, secure, and manageable microservices architecture. It leverages EKS for container orchestration, ECR for container image storage, VPC for network isolation, NLB for load balancing, IAM for access control, API Gateway for RESTful service exposure, and AWS App Mesh for microservices communication and management.
##### Testing and Validation
- Create scenarios to demonstrate the working of rate limiting and authentication in the API Gateway.
- Validate secure communication between services with mTLS in the service mesh.
###### Scenario 1: Rate Limiting Tests in API Gateway
- **Objective**: To demonstrate rate limiting and validate secure communications between services with mTLS, I've ensured the API remains highly available and resilient against traffic spikes to restrict the number of requests a user can make within a specified timeframe.
- **Setup**:
	- _Rate Limit:_ X number of requests per second (RPS) with a burst capacity of Y requests.
	- _API Method_: A POST method on `/orders` resource.
	- _Testing Tool:_ Simple script that generates HTTP requests at a specified rate.
- **Execution**:
	1. **Normal Operation**: 50 RPS to the `/orders` endpoint.
	2. **Burst Traffic**: Increase the load to simulate a burst of 25 RPS for 10 seconds.
	3. **Over Limit**: Ramp up traffic to 150 RPS for a duration of 15 seconds, exceeding the defined rate limit.
- **Expected Outcomes**:
	- During ***Normal Operation***, all requests are processed successfully with `HTTP 200` responses.
	- For ***Burst Traffic***, the first 20 requests are processed, and subsequent requests may be throttled until the rate falls back within limits.
	- During the ***Over Limit*** testing, requests exceeding the rate limit of 100 RPS receive `HTTP 429` (Too Many Requests) responses, indicating that throttling is in effect. API Gateway logs in CloudWatch should record such behavior.
######  Scenario 2: Validating Secure Communication with mTLS in AWS AppMesh
- **Objective**: To ensure that microservices within an AWS AppMesh communicate securely using mTLS, verifying both the identity of the client and the server during the handshake process.
- **Setup**:
	- AWS AppMesh with the three e-commerce microservices, configured to communicate over mTLS.
	- Each service is represented by a virtual node in the mesh and has a corresponding virtual service.
	- mTLS is enabled on the virtual node for a service as a client and a separate service as a server.
- **Execution**:
	1. **Configuration Validation**: AppMesh configuration should show that mTLS is enabled correctly for the services. This involves verifying the certificate authority (CA) used, the certificates attached to the virtual nodes, and the enforced policy for mTLS.
	2. **Successful Communication**: Initiate a request (i.e. `POST` to _user-service_ to make login, then `GET` to _products-service_ to list products, then `POST` to _orders-service_ to create an order) to simulate a legitimate service-to-service request within the mesh.
	5. **Certificate Validation Failure**: Modify one of the services (i.e. client) to present an invalid certificate or no certificate to the other service (i.e. server)
- **Expected Outcomes**:
	- For **Configuration Validation**, the AWS AppMesh console or CLI shows that mTLS is enabled with the correct CA and certificates.
	- During **Successful Communication**, the client (one of the services) and the server (a different service) successfully establish a secure connection with mutual authentication, allowing data to be exchanged securely.
	- **Certificate Validation Failure**, One of the services (i.e. the server) rejects the connection from the other service (i.e. the client) due to failed mTLS negotiation, demonstrating requirement to secure communication policies within the mesh.
	- Use AWS CloudWatch and AWS X-Ray to monitor traffic and errors within AppMesh. 
		- Failed mTLS negotiations result in visible errors and alerts, indicating issues with certificates or configuration
##### Inference
- From the project's root directory, run the following commands:
	- Provision the infra via AWS Cloudformation
		- `source scripts/create_stack.sh`
	- Push Docker images to ECR
		- `source scripts/push_to_ecr.sh`
	- Apply service, deployment, and Ingress configurations for K8's
		- `source scripts/deploy_k8s.sh`
##### Remaining Work
- Finish successfully testing and validation
- Finish implementing mTLS and additional Cloudwatch logging
- Finish request transformations
##### Appendix
`kubectl get deployments`
`kubectl get services`
`kubectl get pods`
`kubectl get nodes`

`kubectl describe pod pod-name`
`kubectl logs pod-name`
`kubectl logs pod-name -c container-name`

`curl -X POST -H "Content-Type: application/json" -d {\"key\": \"value\"} "{invoke-url}/users"`
`curl -X POST -H "Content-Type: application/json" -d {\"key\": \"value\"} "{invoke-url}/orders"`
`curl -X POST -H "Content-Type: application/json" -d {\"key\": \"value\"} "{invoke-url}/products"`