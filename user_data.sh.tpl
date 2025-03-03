#!/bin/bash
# Update the system
sudo yum update -y

# Install Docker
sudo yum install -y docker
sudo service docker start
sudo systemctl enable docker

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.22.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null
then
    # Install AWS CLI
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
fi

# Add ec2-user to the Docker group
sudo usermod -aG docker ec2-user

# Install and configure the CloudWatch Logs Agent
sudo yum install -y amazon-cloudwatch-agent

# Configure the CloudWatch Agent
cat <<EOF > /opt/aws/amazon-cloudwatch-agent/bin/config.json
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/lib/docker/containers/**/*-json.log",
            "log_group_name": "/myapp/docker-logs",
            "log_stream_name": "{instance_id}",
            "timezone": "UTC"
          }
        ]
      }
    }
  },
  "metrics": {
    "metrics_collected": {
      "cpu": {
        "measurement": [
          "cpu_usage_idle",
          "cpu_usage_user",
          "cpu_usage_system"
        ],
        "resources": [
          "*"
        ],
        "totalcpu": true
      },
      "disk": {
        "measurement": [
          "used_percent",
          "inodes_free"
        ],
        "resources": [
          "/"
        ]
      },
      "mem": {
        "measurement": [
          "mem_used_percent"
        ]
      },
      "net": {
        "measurement": [
          "bytes_sent",
          "bytes_recv"
        ]
      }
    }
  }
}
EOF

# Start the CloudWatch Agent
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json -s

# Create and set permissions for docker-compose.yml
cat <<EOF > /home/ec2-user/docker-compose.yml
services:
  frontend:
    # shellcheck disable=SC2154
    image: ${frontend_ecr_repository}:latest
    container_name: frontend
    networks:
      - app-network
    volumes:
      - frontend-build:/app/build
    command: >
      sh -c "touch /app/build/BUILD_COMPLETE"

  backend:
    # shellcheck disable=SC2154
    image: ${backend_ecr_repository}:latest
    container_name: backend
    ports:
      - "5000:5000"
    networks:
      - app-network
    volumes:
      - frontend-build:/app/../frontend/build:ro
    depends_on:
      - frontend
    command: >
      sh -c 'while [ ! -f /app/../frontend/build/BUILD_COMPLETE ]; do
      echo "Waiting for frontend build..."; sleep 5; done &&
      gunicorn --bind 0.0.0.0:5000 run:app'
    restart: always

volumes:
  frontend-build: {}

networks:
  app-network:
    driver: bridge
EOF

sudo chown ec2-user:ec2-user /home/ec2-user/docker-compose.yml

# Create startup script
cat <<EOF > /home/ec2-user/startup.sh
#!/bin/bash
# Navigate to the working directory
cd /home/ec2-user

# Stop and remove Docker Compose containers, networks, and volumes
echo "Stopping and removing Docker Compose environment..."
/usr/local/bin/docker-compose down -v

# Authenticate with AWS ECR
echo "Logging into AWS ECR..."
aws ecr get-login-password --region eu-central-1 | docker login --username AWS --password-stdin ${frontend_ecr_repository%%/*}

# Start containers with the latest images
echo "Starting Docker containers..."
/usr/local/bin/docker-compose up -d --pull always

echo "Startup script completed successfully!"
EOF

# Make startup script executable and set ownership
chmod +x /home/ec2-user/startup.sh
sudo chown ec2-user:ec2-user /home/ec2-user/startup.sh

# Install Cronie
sudo yum install cronie -y
sudo systemctl enable crond
sudo systemctl start crond

# Add startup script to crontab for ec2-user
sudo -u ec2-user crontab -l 2>/dev/null | grep -q "startup.sh" || (sudo -u ec2-user crontab -l 2>/dev/null; echo "@reboot /bin/bash /home/ec2-user/startup.sh >> /home/ec2-user/cron.log 2>&1") | sudo -u ec2-user crontab -

# Reboot to apply changes
sudo reboot