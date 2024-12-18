FROM jenkins/jenkins:lts

# Install Java
USER root
RUN apt-get update && \
    apt-get apt install openjdk-17-jre -y && \
    apt-get apt install openjdk-17-jdk -y && \
    apt-get clean

# Install Trivy
RUN wget https://github.com/aquasecurity/trivy/releases/latest/download/trivy_Linux-64bit.deb && \
    dpkg -i trivy_Linux-64bit.deb && \
    rm trivy_Linux-64bit.deb

# Switch back to Jenkins user
USER jenkins
