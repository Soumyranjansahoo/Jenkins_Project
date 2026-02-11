#!/bin/bash
set -e

echo "=== Installing Apache Maven 3.9.12 ==="

# Update packages
sudo yum update -y

# Download Maven 3.9.12
cd /tmp
wget https://downloads.apache.org/maven/maven-3/3.9.12/binaries/apache-maven-3.9.12-bin.tar.gz

# Extract Maven
sudo tar -xf apache-maven-3.9.12-bin.tar.gz -C /opt

# Create symlink for easy version switching
sudo rm -f /opt/maven
sudo ln -s /opt/apache-maven-3.9.12 /opt/maven

# Configure environment variables
sudo tee /etc/profile.d/maven.sh > /dev/null <<EOF
export M2_HOME=/opt/maven
export PATH=\$M2_HOME/bin:\$PATH
EOF

# Apply the environment changes
source /etc/profile.d/maven.sh

echo "=== Maven installation completed ==="

# Verify installation
mvn -v
