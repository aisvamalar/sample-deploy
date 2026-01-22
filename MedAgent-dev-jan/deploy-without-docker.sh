#!/bin/bash

# MedAgent AWS EC2 Deployment Script (Without Docker)
# Alternative deployment using systemd services

set -e  # Exit on error

echo "========================================="
echo "MedAgent AWS EC2 Deployment (No Docker)"
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
    nginx \
    curl \
    git \
    ufw

# Configure firewall
echo "Step 3: Configuring firewall..."
sudo ufw allow 22/tcp   # SSH
sudo ufw allow 80/tcp   # HTTP
sudo ufw allow 443/tcp  # HTTPS
sudo ufw allow 8000/tcp # Backend API
sudo ufw allow 8501/tcp # Frontend
sudo ufw --force enable

# Create application directory
echo "Step 4: Setting up application directory..."
APP_DIR="/opt/medagent"
sudo mkdir -p $APP_DIR
sudo chown $USER:$USER $APP_DIR

# Clone repository
echo "Step 5: Cloning repository from GitHub..."
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

# Create virtual environment
echo "Step 6: Creating Python virtual environment..."
python3.11 -m venv .venv
source .venv/bin/activate

# Install dependencies
echo "Step 7: Installing Python dependencies..."
pip install --upgrade pip
pip install -r requirements.txt

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

# Install systemd services
echo "Step 9: Installing systemd services..."
# Copy service files (paths are already correct in the files)
sudo cp systemd/medagent-backend.service /etc/systemd/system/
sudo cp systemd/medagent-frontend.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable medagent-backend
sudo systemctl enable medagent-frontend
sudo systemctl start medagent-backend
sudo systemctl start medagent-frontend

# Configure Nginx
echo "Step 10: Configuring Nginx..."
sudo cp nginx.conf /etc/nginx/nginx.conf
sudo nginx -t
sudo systemctl restart nginx
sudo systemctl enable nginx

# Wait for services to start
echo "Step 11: Waiting for services to start..."
sleep 5

# Check service status
echo "Step 12: Checking service status..."
sudo systemctl status medagent-backend --no-pager
sudo systemctl status medagent-frontend --no-pager

# Display access information
PUBLIC_IP=$(curl -s ifconfig.me)
echo ""
echo "========================================="
echo "Deployment Complete!"
echo "========================================="
echo ""
echo "Services are running:"
echo "  - Backend API: http://$PUBLIC_IP:8000"
echo "  - Frontend UI: http://$PUBLIC_IP:8501"
echo "  - Nginx Proxy: http://$PUBLIC_IP"
echo ""
echo "Useful commands:"
echo "  - View backend logs: sudo journalctl -u medagent-backend -f"
echo "  - View frontend logs: sudo journalctl -u medagent-frontend -f"
echo "  - Restart backend: sudo systemctl restart medagent-backend"
echo "  - Restart frontend: sudo systemctl restart medagent-frontend"
echo "  - Check status: sudo systemctl status medagent-backend medagent-frontend"
echo ""
