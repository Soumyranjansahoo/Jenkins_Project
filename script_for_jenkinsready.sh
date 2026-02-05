#!/bin/bash
set -e

# Detect package manager
if command -v dnf >/dev/null 2>&1; then
  PKG=dnf
else
  PKG=yum
fi

echo "[1/4] Installing utilities..."
sudo $PKG -y install curl wget tar

echo "[2/4] Installing Amazon Corretto 21..."
sudo rpm --import https://yum.corretto.aws/corretto.key
sudo curl -fsSL -o /etc/yum.repos.d/corretto.repo https://yum.corretto.aws/corretto.repo
sudo $PKG install -y java-21-amazon-corretto-devel

echo "[3/4] Installing Maven 3.9.12..."
MAVEN_VERSION=3.9.12
sudo mkdir -p /opt
cd /opt
sudo curl -fLo apache-maven.tar.gz \
  https://dlcdn.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz
sudo tar -xzf apache-maven.tar.gz
sudo ln -sfn /opt/apache-maven-$MAVEN_VERSION /opt/maven
sudo rm -f apache-maven.tar.gz

# Permanent Maven PATH fix for Jenkins
echo "export MAVEN_HOME=/opt/maven" | sudo tee /etc/profile.d/maven.sh >/dev/null
echo 'export PATH=/opt/maven/bin:$PATH' | sudo tee -a /etc/profile.d/maven.sh >/dev/null

# Add Maven PATH directly to Jenkins environment
echo 'PATH=/opt/maven/bin:$PATH' | sudo tee -a /etc/sysconfig/jenkins >/dev/null

echo "[4/4] Installing Jenkins LTS..."
sudo rm -f /etc/yum.repos.d/jenkins.repo || true
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/rpm-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/rpm-stable/jenkins.io-2026.key

sudo $PKG clean all
sudo $PKG makecache || true
sudo $PKG install -y jenkins

sudo systemctl enable jenkins
sudo systemctl restart jenkins

# Open firewall port 8080 if available
if command -v firewall-cmd >/dev/null 2>&1; then
  sudo firewall-cmd --permanent --add-port=8080/tcp
  sudo firewall-cmd --reload
fi

echo
echo "Jenkins installed and Maven is available to all Jenkins jobs."
echo "Access Jenkins at: http://<server-ip>:8080"
echo "Initial admin password:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword || echo "Wait 30 seconds..."
