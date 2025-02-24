#!/bin/bash
sudo service docker start  # Ensure Docker is running
/usr/bin/docker volume inspect ec2-user_frontend-build > /dev/null 2>&1 && /usr/bin/docker volume rm ec2-user_frontend-build || true
aws ecr get-login-password --region eu-central-1 | docker login --username AWS --password-stdin 225989349529.dkr.ecr.eu-central-1.amazonaws.com
cd /home/ec2-user
/usr/local/bin/docker-compose up -d --pull always