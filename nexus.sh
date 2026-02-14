#!/bin/bash

# Simple Nexus Install Script (Java 21 already installed)

cd /opt

# Download Nexus (latest stable 3.88)
wget https://download.sonatype.com/nexus/3/nexus-3.88.0-08-unix.tar.gz -O nexus.tgz

# Extract
tar -xvf nexus.tgz
mv nexus-3.88.0-08 nexus

# Create data folder
mkdir -p /opt/sonatype-work
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

# Start service
systemctl daemon-reload
systemctl enable nexus
systemctl start nexus

echo "Nexus installed!"
echo "Open in browser: http://<your-ip>:8081/"
echo "Admin password file: /opt/sonatype-work/nexus3/admin.password"
