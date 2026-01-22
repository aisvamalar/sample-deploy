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
    docker.io \
    nginx \
    curl \
    git \
    ufw \
    ca-certificates \
    gnupg \
    lsb-release

# Start and enable Docker (needed before checking compose)
echo "Step 3: Setting up Docker..."
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER

# Install Docker Compose (plugin version for Ubuntu 22.04+)
echo "Step 4: Installing Docker Compose..."
# Try to install docker-compose-plugin first
if sudo apt-get install -y docker-compose-plugin 2>/dev/null; then
    echo "Docker Compose plugin installed successfully"
elif command -v docker-compose &> /dev/null; then
    echo "Docker Compose standalone already available"
else
    # Fallback: install standalone docker-compose
    echo "Installing Docker Compose standalone..."
    DOCKER_COMPOSE_VERSION="v2.24.0"
    sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    echo "Docker Compose standalone installed"
fi

# Configure firewall
echo "Step 5: Configuring firewall..."
sudo ufw allow 22/tcp   # SSH
sudo ufw allow 80/tcp   # HTTP
sudo ufw allow 443/tcp  # HTTPS
sudo ufw --force enable

# Create application directory
echo "Step 6: Setting up application directory..."
APP_DIR="/opt/medagent"
sudo mkdir -p $APP_DIR
sudo chown $USER:$USER $APP_DIR

# Clone repository
echo "Step 7: Cloning repository from GitHub..."
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
    echo "Step 8: Creating .env file from template..."
    cp env.example .env
    echo ""
    echo "⚠️  IMPORTANT: Please edit $APP_DIR/sample-deploy/MedAgent-dev-jan/.env and add your GROQ_API_KEY"
    echo "   Run: nano $APP_DIR/sample-deploy/MedAgent-dev-jan/.env"
    echo ""
    read -p "Press Enter after you've configured .env file..."
fi

# Build and start Docker containers
echo "Step 9: Building and starting Docker containers..."
# Use docker compose (plugin) or docker-compose (standalone)
if command -v docker &> /dev/null && docker compose version &> /dev/null; then
    docker compose build
    docker compose up -d
else
    docker-compose build
    docker-compose up -d
fi

# Wait for services to be ready
echo "Step 10: Waiting for services to start..."
sleep 10

# Check service status
echo "Step 11: Checking service status..."
if command -v docker &> /dev/null && docker compose version &> /dev/null; then
    docker compose ps
else
    docker-compose ps
fi

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
echo "  - View logs: cd $APP_DIR/sample-deploy/MedAgent-dev-jan && docker compose logs -f"
echo "  - Stop services: cd $APP_DIR/sample-deploy/MedAgent-dev-jan && docker compose down"
echo "  - Restart services: cd $APP_DIR/sample-deploy/MedAgent-dev-jan && docker compose restart"
echo "  - Update application: cd $APP_DIR/sample-deploy && git pull && cd MedAgent-dev-jan && docker compose up -d --build"
echo ""
echo "Note: If 'docker compose' doesn't work, use 'docker-compose' instead"
echo ""
echo "Note: You may need to log out and back in for Docker group changes to take effect."
echo ""
