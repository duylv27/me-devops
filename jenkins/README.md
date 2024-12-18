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

## Common command
- Install jenkins on Ubuntu.
```
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
