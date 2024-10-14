# Sample User Service #

## Overview ##

This example use the demonstrate the technologies
   - Swagger UI 
   - Deployment to Docker desktop
        * Nginx load balancer
        * Replication of service 

## URLS
- End point to see environment variable using actuator:  http://localhost:8081/actuator/env
- Swagger end point: http://localhost:8080/swagger-ui/index.html

## Replication and Load Balancing using NGINX
To replicate the services we need to solve the issue with host port conflict. The host machine can only bind an unallocated port to one container only, otherwise  we get an error "failed: port is already allocated error for additional XXX service".

- Use the load balancer will access the back end service without exposing the container ports and distribute the traffic across multiple containers.

Here is the overview of load balancing using NGINX
<img src="https://github.com/sriharijala/SpringExamples/blob/main/jpa-hibernate_crud/src/main/resources/images/nginx_lb.png"/>

```
nginx.conf

user  nginx;
events {
    worker_connections   1000;
}
http {
        server {
              listen 80;
              location / {
                proxy_pass http://user-reviews:8080;
              }
        }
}
```

- In docker-compose.yml expose only the container port

```
services:
  user-reviews:
    image: sjala/user-reviews:latest
    depends_on:
       - mysql
    expose:
      - "8080"
```

## Terrform commands ##
- Initialize terraform                           : ``terraform init``
- Execuate the plan                              : ``terraform plan``
- Create the infrastucture with auto approve     : ``terraform plan --auto-approve=true``
- Get teh private key to ssh to ec2BationKey     : ``terraform output -raw ec2BationKey``
- Remove the entire infrastucture auto approve   : ``terraform destroy --auto-approve=true``
- List all resources crated                      : ``terraform state list``
- Rmove selective resource                       : ``terraform destroy --target resource_name --auto-approve=true``

## Docker commands

- Build Docker image                            : ``docker build -t sjala/user-reviews:1.0 .``
- Push docker image to Docker Hub         : ``docker push sjala/user-reviews:1.0``
- Deploy in docker desktop 			          : ``docker compose --env-file=user-reviews.env up -d --scale user-reviews=3``

### Push Docker image to ECR

####Login to AWS ECR
#####Note : In case Windows, use set REPO=aws_ecr_repo_url and reference variable with %REPO%
#####Create a repo in ECR and get AWS repo url from aws
    ``export REPO=aws_ecr_repo_url``
    ``aws ecr get-login-password | docker login --username AWS --password-stdin $REPO``
    
#####Pull docker image & push to our ECR
    ``aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin``
    ``docker tag sjala/user-reviews:latest $REPO/sjala/user-reviews:latest``
    ``docker push $REPO:latest``

### Installing Jenkins Server
 - <a href="https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/EC2_GetStarted.html">Create new EC2 instance</a>
 - <a href="https://www.jenkins.io/doc/tutorials/tutorial-for-installing-jenkins-on-AWS/">Install Jenkins on new EC2</a>
 - Jenkins server root access - ``sudo su``
 - Change user to jenkins : ``sudo su -s /bin/bash jenkins``
 - Restarting Jenkins - ``sudo systemctl restart jenkins``
 - <a href="https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html">Install AWS CLI</a>
 - <a href="https://eksctl.io/installation/">Install cksctl</a>
 - <a href="https://docs.aws.amazon.com/eks/latest/userguide/helm.html">Install helm</a>
 - Install Git 
 
 ```
    sudo yum update -y
    sudo yum install git -y
    git --version
    git config --global user.name “Your Name”
    git config --global user.email “your_email@example.com”
```

###Install the helm-s3 plugin in Jenkin server for Amazon S3 access.

```
sudo su -s /bin/bash jenkins # You must use "jenkins" user.
export PATH=$PATH:/usr/local/bin
helm version
helm plugin install https://github.com/hypnoglow/helm-s3.git
```

 - Configure AWS CLI
     - ``[ec2-user@ip-172-31-45-206 jenkins]$ aws configure``
     - ``AWS Access Key ID [None]: <enter-access-key-id>``
     - ``AWS Secret Access Key [None]: <enter-access-key>``

### Create cluster
Creating cluster.yaml file In order to create an AWS EKS cluster, firstly, create a cluster.yaml file under the /var/lib/jenkins folder, and use the following content, as shown in the figure below. Use the sudo nano cluster.yamlcommand to create cluster.yamlfile.

#####Configuration
```
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: petclinic-cluster
  region: us-east-1
availabilityZones: ["us-east-1a", "us-east-1b", "us-east-1c"]
managedNodeGroups:
  - name: ng-1
    instanceType: t2.micro
    desiredCapacity: 2
    minSize: 2
    maxSize: 3
    volumeSize: 8
```

#### Create cluster
eksctl create cluster -f cluster.yaml

###Create Amazon S3 Bucket
   - Create an S3 bucket to store Helm charts. : eks-monitoring-with-anteon-helm-charts
   - Create folder :  stable/myapp
   
   
###Create Jenkins pipeline

```
- job name: eks-cluster-with-monitoring-anteon
- job type: pipeline
- Description: The production pipeline deploys the Dearing Veterinairan Clinic Java-based web application consisting of 11 microservices to the Amazon EKS cluster with Helm. We'll monitor Amazon EKS cluster with Anteon.
In the this stage, Whenever the developers push their codes to the GitHub repository, the Jenkins pipeline will run automatically thanks to the GitHub webhook and automatically update our Java-based application running on the web.
- Discard old builds: Days to keep builds=2, Max of builds to keep=2.
- GitHub project: Project url=https://github.com/cmakkaya/eks-monitoring-with-anteon
- Build Triggers:
      Build periodically: 
- Source Code Management: Git
      Repository URL: https://github.com/cmakkaya/eks-monitoring-with-anteon.git
- Branches to build:
      Branch Specifier: */main 
- Pipeline:
      Script Path: jenkins/jenkinsfile-microservice-app-production
```


