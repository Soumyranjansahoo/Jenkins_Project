
#!/bin/bash
set -e
sudo rpm --import https://yum.corretto.aws/corretto.key
sudo curl -fsSL -o /etc/yum.repos.d/corretto.repo https://yum.corretto.aws/corretto.repo
sudo yum install -y java-21-amazon-corretto-devel

java --version


echo "******JAVA installed ***************"


