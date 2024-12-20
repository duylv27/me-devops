# Jenkins

---

## One sentence for Jenkins

Jenkins is an open-source automation server that enables **continuous integration** 
and **continuous delivery** (CI/CD) by automating the building, testing, 
and deployment of applications.

---

## Dictionary

### Shared Library
A Jenkins Shared Library is a **reusable, centralized collection of 
Groovy scripts and custom functions** that can be shared across multiple
Jenkins pipelines, enabling modularization, 
code reuse, and consistent implementation of CI/CD processes.

### Jenkins Agent
### Jenkins Node

---
## Common commands
### 1. Installation

#### 1.1. Local Ubuntu
```bash
# Install
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key |sudo gpg --dearmor -o /usr/share/keyrings/jenkins.gpg
sudo sh -c 'echo deb [signed-by=/usr/share/keyrings/jenkins.gpg] http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt update
sudo apt install jenkins

# Start
sudo systemctl start jenkins

# Stop
sudo systemctl stop jenkins

# Restart
sudo systemctl restart jenkins

# Remove
sudo apt remove --purge jenkins
```

---

#### 1.2. AWS - EC2 Linux
```bash
sudo yum update –y

# Install Jenkins
sudo wget -O /etc/yum.repos.d/jenkins.repo \
    https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo yum upgrade
sudo dnf install java-17-amazon-corretto -y
sudo yum install jenkins -y

# Start Jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins
sudo systemctl status jenkins

sudo cat /var/lib/jenkins/secrets/initialAdminPassword

# Install git
sudo yum install git -y

# Install git
sudo yum install docker
sudo systemctl start docker
sudo usermod -a -G docker jenkins

# Install kubectl
curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.27.16/2024-11-15/bin/linux/amd64/kubectl
chmod +x ./kubectl
mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$HOME/bin:$PATH

# aws eks update-kubeconfig --region <region> --name <cluster name>
# aws eks update-kubeconfig --region us-east-1 --name eks_cluster
# curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.27.16/2024-11-15/bin/linux/amd64/kubectl
# chmod +x ./kubectl
# mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$HOME/bin:$PATH
```

---

### 2. Setup

#### 2.1. Suggested Plugins:
- Docker Pipeline
- Pipeline Utility Steps
- Stage View

#### 2.2. Credentials
Usually credentials to access source code. It should be `github`, `gitlab`, `docker` access key, etc.