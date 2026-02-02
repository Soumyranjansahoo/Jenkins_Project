# 1) Pick a version (3.9.12 is current in the 3.9 line)
MAVEN_VERSION=3.9.12

# 2) Download & install under /opt
cd /opt
sudo curl -L -o apache-maven.tar.gz \
  https://dlcdn.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz
sudo tar -xzf apache-maven.tar.gz
sudo ln -sfn /opt/apache-maven-${MAVEN_VERSION} /opt/maven
sudo rm -f apache-maven.tar.gz

# 3) Put it on PATH system-wide
echo 'export MAVEN_HOME=/opt/maven' | sudo tee /etc/profile.d/maven.sh
echo 'export PATH=$MAVEN_HOME/bin:$PATH' | sudo tee -a /etc/profile.d/maven.sh
source /etc/profile.d/maven.sh

# 4) Verify
mvn -version
