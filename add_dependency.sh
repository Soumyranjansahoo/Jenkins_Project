#!/bin/bash
set -euo pipefail

echo "==============================================="
echo " Jenkins LTS + Amazon Corretto 21 + Maven 3.9.12"
echo "==============================================="

# Detect package manager (dnf preferred on RHEL 8/9, yum on others)
if command -v dnf >/dev/null 2>&1; then
  PKG=dnf
else
  PKG=yum
fi

#-------------------------------
# 0) Basic utilities
#-------------------------------
sudo ${PKG} -y install curl wget tar

#-------------------------------
# 1) Install Amazon Corretto 21 (JDK)
#-------------------------------
echo "[1/5] Installing Amazon Corretto 21..."
sudo rpm --import https://yum.corretto.aws/corretto.key
sudo curl -fsSL -o /etc/yum.repos.d/corretto.repo https://yum.corretto.aws/corretto.repo
sudo ${PKG} install -y java-21-amazon-corretto-devel
echo "Java installed:"
java --version || true

#-------------------------------
# 2) Install Apache Maven 3.9.12 under /opt
#-------------------------------
echo "[2/5] Installing Maven 3.9.12..."
MAVEN_VERSION=3.9.12
cd /opt
sudo curl -fL --retry 3 --retry-connrefused \
  -o apache-maven.tar.gz \
  "https://dlcdn.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz"

sudo tar -xzf apache-maven.tar.gz
sudo ln -sfn "/opt/apache-maven-${MAVEN_VERSION}" /opt/maven
sudo rm -f apache-maven.tar.gz

# Add to PATH for all users
sudo tee /etc/profile.d/maven.sh >/dev/null <<'EOF'
export MAVEN_HOME=/opt/maven
export PATH=$MAVEN_HOME/bin:$PATH
EOF
# Apply for current shell if interactive
source /etc/profile.d/maven.sh || true

echo "Maven installed:"
mvn -version || true

#-------------------------------
# 3) Configure Jenkins LTS repository (rpm-stable) + new 2026 key
#-------------------------------
echo "[3/5] Configuring Jenkins LTS repository..."

# Remove any older/weekly repo definition to avoid conflicts
sudo rm -f /etc/yum.repos.d/jenkins.repo || true

# Use the rpm-stable repo (LTS)
sudo wget -O /etc/yum.repos.d/jenkins.repo \
  https://pkg.jenkins.io/rpm-stable/jenkins.repo

# Import the new 2026 repository/package signing key for LTS
sudo rpm --import https://pkg.jenkins.io/rpm-stable/jenkins.io-2026.key

# Ensure metadata is fresh
sudo ${PKG} clean all
sudo ${PKG} makecache || true

#-------------------------------
# 4) Install Jenkins LTS and start service
#-------------------------------
echo "[4/5] Installing Jenkins LTS..."
sudo ${PKG} install -y jenkins

echo "Enabling and starting Jenkins service..."
sudo systemctl enable jenkins
sudo systemctl start jenkins

echo "Jenkins service status (summary):"
sudo systemctl --no-pager --full status jenkins || true

#-------------------------------
# 5) Open firewall port 8080 (if firewalld is present)
#-------------------------------
if command -v firewall-cmd >/dev/null 2>&1; then
  echo "[5/5] Opening firewall port 8080..."
  sudo firewall-cmd --permanent --add-port=8080/tcp
  sudo firewall-cmd --reload
fi

#-------------------------------
# Output initial admin password
#-------------------------------
echo
echo "==============================================="
echo " Jenkins LTS installation complete!"
echo " Access:  http://<server-ip>:8080"
echo " Initial admin password (copy/paste below):"
if [ -f /var/lib/jenkins/secrets/initialAdminPassword ]; then
  sudo cat /var/lib/jenkins/secrets/initialAdminPassword
else
  echo "  (Password not yet generated; Jenkins is still starting. Try again in ~30s)"
fi
echo "==============================================="
set -e

echo "###############################################"
echo " Installing Java 21 + Maven 3.9.12 + Jenkins   "
echo "###############################################"


##########################################
# 1) Install Java 21 (Amazon Corretto)
##########################################
echo ">>> Installing Java 21..."

sudo rpm --import https://yum.corretto.aws/corretto.key
sudo curl -L -o /etc/yum.repos.d/corretto.repo https://yum.corretto.aws/corretto.repo

sudo yum install -y java-21-amazon-corretto-devel

echo ">>> Java installed:"
java --version


##########################################
# 2) Install Apache Maven 3.9.12
##########################################
echo ">>> Installing Maven 3.9.12..."

MAVEN_VERSION=3.9.12
cd /opt

sudo curl -L -o apache-maven.tar.gz \
  https://dlcdn.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz

sudo tar -xzf apache-maven.tar.gz
sudo ln -sfn /opt/apache-maven-${MAVEN_VERSION} /opt/maven
sudo rm -f apache-maven.tar.gz

sudo tee /etc/profile.d/maven.sh > /dev/null <<EOF
export MAVEN_HOME=/opt/maven
export PATH=\$MAVEN_HOME/bin:\$PATH
EOF

source /etc/profile.d/maven.sh

echo ">>> Maven installed:"
mvn -version


##########################################
# 3) Install Jenkins
##########################################
echo ">>> Installing Jenkins..."

sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/rpm/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat/jenkins.io-2023.key

sudo yum install -y jenkins

echo ">>> Enabling and starting Jenkins..."
sudo systemctl enable jenkins
sudo systemctl start jenkins

echo ">>> Jenkins status:"
sudo systemctl status jenkins --no-pager


##########################################
# 4) Open firewall (optional)
##########################################
if command -v firewall-cmd &> /dev/null
then
    echo ">>> Configuring firewall for Jenkins (port 8080)..."
    sudo firewall-cmd --permanent --add-port=8080/tcp
    sudo firewall-cmd --reload
fi


##########################################
# 5) Print Jenkins Admin Password
##########################################
echo ">>> Jenkins initial admin password:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
source /etc/profile.d/maven.sh
echo "###############################################"
echo " Installation Complete!                        "
echo " Access Jenkins at: http://<server-ip>:8080    "
echo "###############################################"
