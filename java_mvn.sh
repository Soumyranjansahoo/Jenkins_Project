
#!/bin/bash
set -e

echo "=== Checking Java Installation ==="

if ! command -v java >/dev/null 2>&1; then
    echo "Java not found. Installing Amazon Corretto 21..."

    sudo yum update -y

    # Install Java 21 (Amazon Corretto)
    sudo yum install -y java-21-amazon-corretto-devel

    echo "Java 21 installed."
else
    echo "Java already installed."
fi

# Verify Java version
java -version

echo "=== Installing Apache Maven 3.9.12 ==="

# Download Maven (official recommended method)
cd /tmp
wget https://downloads.apache.org/maven/maven-3/3.9.12/binaries/apache-maven-3.9.12-bin.tar.gz

# Extract Maven
sudo tar -xf apache-maven-3.9.12-bin.tar.gz -C /opt

# Create symlink
sudo rm -f /opt/maven
sudo ln -s /opt/apache-maven-3.9.12 /opt/maven

# Environment variables
sudo tee /etc/profile.d/maven.sh > /dev/null <<EOF
export M2_HOME=/opt/maven
export PATH=\$M2_HOME/bin:\$PATH
EOF

# Apply environment
source /etc/profile.d/maven.sh

echo "=== Maven installation completed ==="

# Verify Maven
mvn -v
