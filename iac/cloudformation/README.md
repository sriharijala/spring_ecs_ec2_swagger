# File Organisation

#Ref: https://medium.com/carlos-hernandez/how-to-deploy-a-microservice-using-elastic-container-service-in-aws-b1ac20685f4

* **vpc-network**: The code to create the VPC, the private subnets and the public subnets.
* **rds-database**: The code to create the MySQL database inside our private subnets.
* **ecs-cluster**: The code to create a ECS cluster.
* **ecr**: The code to create the ERC repository.
* **ecs-stack**: The code to create the Task Definition, Service and the Application Load Balancer.
