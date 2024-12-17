# Steps

1. Define terraform
    - `EC2`
    - `VPC`
    - `EKS`
    - `ECR`
2. Install needed stuff on EC2:
  - Jenkins.
    - Plugin:
      - `kubernetes`
      - `ec2`
      - `docker pipeline`
      - `ecr`
    - Credential:
      - `github`
      - `AWS`
  - Docker.
    - `sudo usermod -aG docker jenkins`
  - Java.
  - K8s.
  - Helm.