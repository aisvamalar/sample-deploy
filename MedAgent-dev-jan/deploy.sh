#!/bin/bash

# MedAgent AWS EC2 Deployment Script
# This script sets up the application on a fresh Ubuntu EC2 instance

set -e  # Exit on error

echo "========================================="
echo "MedAgent AWS EC2 Deployment Script"
echo "========================================="

# Update system packages
echo "Step 1: Updating system packages..."
sudo apt-get update
sudo apt-get upgrade -y

# Install required system packages
echo "Step 2: Installing system dependencies..."
sudo apt-get install -y \
    python3.11 \
    python3.11-venv \
    python3-pip \
    docker.io \
    docker-compose \
    nginx \
    curl \
    git \
    ufw

# Start and enable Docker
echo "Step 3: Setting up Docker..."
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER

# Configure firewall
echo "Step 4: Configuring firewall..."
sudo ufw allow 22/tcp   # SSH
sudo ufw allow 80/tcp   # HTTP
sudo ufw allow 443/tcp  # HTTPS
sudo ufw --force enable

# Create application directory
echo "Step 5: Setting up application directory..."
APP_DIR="/opt/medagent"
sudo mkdir -p $APP_DIR
sudo chown $USER:$USER $APP_DIR

# Clone repository
echo "Step 6: Cloning repository from GitHub..."
cd $APP_DIR
GIT_REPO="https://github.com/aisvamalar/sample-deploy.git"
if [ -d "sample-deploy" ]; then
    echo "Repository already exists. Pulling latest changes..."
    cd sample-deploy
    git pull
else
    git clone $GIT_REPO
    cd sample-deploy
fi

# Navigate to project directory
cd MedAgent-dev-jan

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo "Step 7: Creating .env file from template..."
    cp env.example .env
    echo ""
    echo "⚠️  IMPORTANT: Please edit $APP_DIR/sample-deploy/MedAgent-dev-jan/.env and add your GROQ_API_KEY"
    echo "   Run: nano $APP_DIR/sample-deploy/MedAgent-dev-jan/.env"
    echo ""
    read -p "Press Enter after you've configured .env file..."
fi

# Build and start Docker containers
echo "Step 8: Building and starting Docker containers..."
docker-compose build
docker-compose up -d

# Wait for services to be ready
echo "Step 9: Waiting for services to start..."
sleep 10

# Check service status
echo "Step 10: Checking service status..."
docker-compose ps

# Display access information
echo ""
echo "========================================="
echo "Deployment Complete!"
echo "========================================="
echo ""
echo "Services are running:"
echo "  - Backend API: http://$(curl -s ifconfig.me):8000"
echo "  - Frontend UI: http://$(curl -s ifconfig.me):8501"
echo "  - Nginx Proxy: http://$(curl -s ifconfig.me)"
echo ""
echo "Useful commands:"
echo "  - View logs: cd $APP_DIR/sample-deploy/MedAgent-dev-jan && docker-compose logs -f"
echo "  - Stop services: cd $APP_DIR/sample-deploy/MedAgent-dev-jan && docker-compose down"
echo "  - Restart services: cd $APP_DIR/sample-deploy/MedAgent-dev-jan && docker-compose restart"
echo "  - Update application: cd $APP_DIR/sample-deploy && git pull && cd MedAgent-dev-jan && docker-compose up -d --build"
echo ""
echo "Note: You may need to log out and back in for Docker group changes to take effect."
echo ""
