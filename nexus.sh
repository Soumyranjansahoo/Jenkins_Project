#!/bin/bash

# Simple Nexus Install Script (Java 21 already installed)

cd /opt

# Download Nexus (latest stable 3.88)
wget https://download.sonatype.com/nexus/3/nexus-3.89.1-02-linux-x86_64.tar.gz

# Extract
tar -xvf nexus.tgz
mv nexus-3.89.0-08 nexus

# Create data folder


useradd nexus || true
chown -R nexus:nexus /opt/nexus /opt/sonatype-work

# Set Nexus to run as nexus user
echo "run_as_user=\"nexus\"" > /opt/nexus/bin/nexus.rc

# Create systemd service
cat > /etc/systemd/system/nexus.service <<EOF
[Unit]
Description=Nexus Repository
After=network.target

[Service]
Type=forking
User=nexus
Group=nexus
ExecStart=/opt/nexus/bin/nexus start
ExecStop=/opt/nexus/bin/nexus stop
Restart=on-abort
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF


sudo mkdir -p /opt/sonatype-work/nexus3/log
sudo mkdir -p /opt/sonatype-work/nexus3/tmp
sudo chown -R nexus:nexus /opt/sonatype-work
# Backup first
sudo cp /opt/nexus/bin/nexus.vmoptions /opt/nexus/bin/nexus.vmoptions.bak.$(date +%F-%H%M%S)

# Set smaller, safer values (adjust if you know your box size)
sudo sed -i \
  -e 's/^-Xms.*$/-Xms1024m/' \
  -e 's/^-Xmx.*$/-Xmx1024m/' \
  -e 's/^-XX:MaxDirectMemorySize=.*$/-XX:MaxDirectMemorySize=512m/' \
  /opt/nexus/bin/nexus.vmoptions

# Start service
systemctl daemon-reload
systemctl enable nexus
systemctl start nexus

echo "Nexus installed!"
echo "Open in browser: http://<your-ip>:8081/"
echo "Admin password file: /opt/sonatype-work/nexus3/admin.password"
