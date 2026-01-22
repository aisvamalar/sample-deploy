# EC2 Deployment Guide (Without Docker)

Simple step-by-step guide to deploy MedAgent on AWS EC2 by cloning from GitHub.

## Prerequisites

- AWS EC2 instance running Ubuntu 22.04 LTS
- EC2 Instance Connect access (or SSH)
- Groq API Key

---

## Step 1: Launch EC2 Instance

1. Go to AWS Console → EC2 → Launch Instance
2. Select **Ubuntu Server 22.04 LTS**
3. Choose instance type: **t3.small** (minimum) or **t3.medium** (recommended)
4. Configure Security Group:
   - Allow SSH (port 22)
   - Allow HTTP (port 80)
   - Allow HTTPS (port 443)
   - Allow Custom TCP 8000 (Backend)
   - Allow Custom TCP 8501 (Frontend)
5. Launch instance

---

## Step 2: Connect to EC2

### Using EC2 Instance Connect (Recommended)

1. EC2 Console → Instances → Select your instance
2. Click **Connect** → **EC2 Instance Connect** tab
3. Click **Connect**

Terminal opens in browser!

### Using SSH (Alternative)

```bash
ssh -i "your-key.pem" ubuntu@<your-ec2-ip>
```

---

## Step 3: Clone Repository

Run these commands in the terminal:

```bash
# Update system
sudo apt-get update

# Install git if not installed
sudo apt-get install -y git curl

# Create application directory
sudo mkdir -p /opt/medagent
sudo chown $USER:$USER /opt/medagent

# Clone repository
cd /opt/medagent
git clone https://github.com/aisvamalar/sample-deploy.git
cd sample-deploy/MedAgent-dev-jan
```

---

## Step 4: Run Deployment Script

```bash
# Make script executable
chmod +x deploy-without-docker.sh

# Run deployment script
./deploy-without-docker.sh
```

The script will:
- Install Python 3 and dependencies
- Create virtual environment
- Install Python packages
- Set up systemd services
- Configure firewall

**This takes 5-10 minutes** - be patient!

---

## Step 5: Configure API Key

When the script prompts you:

```bash
nano .env
```

In the editor:
1. Find: `GROQ_API_KEY=your_groq_api_key_here`
2. Replace with your actual key: `GROQ_API_KEY=gsk_your_actual_key_here`
3. Save: `Ctrl+X`, then `Y`, then `Enter`

---

## Step 6: Restart Services

After editing `.env`:

```bash
# Restart backend
sudo systemctl restart medagent-backend

# Restart frontend
sudo systemctl restart medagent-frontend
```

---

## Step 7: Access Your Application

Get your public IP:
```bash
curl ifconfig.me
```

Access URLs:
- **Frontend**: `http://<your-ip>:8501`
- **Backend API**: `http://<your-ip>:8000`
- **API Docs**: `http://<your-ip>:8000/docs`

---

## Verify Deployment

Check if services are running:

```bash
# Check backend status
sudo systemctl status medagent-backend

# Check frontend status
sudo systemctl status medagent-frontend

# View logs
sudo journalctl -u medagent-backend -f
sudo journalctl -u medagent-frontend -f
```

Press `Ctrl+C` to exit logs.

---

## Useful Commands

### View Logs
```bash
# Backend logs
sudo journalctl -u medagent-backend -f

# Frontend logs
sudo journalctl -u medagent-frontend -f
```

### Restart Services
```bash
sudo systemctl restart medagent-backend
sudo systemctl restart medagent-frontend
```

### Stop Services
```bash
sudo systemctl stop medagent-backend
sudo systemctl stop medagent-frontend
```

### Start Services
```bash
sudo systemctl start medagent-backend
sudo systemctl start medagent-frontend
```

### Check Status
```bash
sudo systemctl status medagent-backend medagent-frontend
```

### Update Application
```bash
cd /opt/medagent/sample-deploy
git pull
cd MedAgent-dev-jan
source .venv/bin/activate
pip install -r requirements.txt
sudo systemctl restart medagent-backend medagent-frontend
```

---

## Troubleshooting

### Services Not Starting

```bash
# Check logs for errors
sudo journalctl -u medagent-backend -n 50
sudo journalctl -u medagent-frontend -n 50

# Check if ports are in use
sudo netstat -tulpn | grep -E '8000|8501'
```

### Cannot Access from Browser

1. **Check Security Group**: Ensure ports 80, 443, 8000, 8501 are open
2. **Check Firewall**: `sudo ufw status`
3. **Check Services**: `sudo systemctl status medagent-backend medagent-frontend`

### Port Already in Use

```bash
# Find what's using the port
sudo lsof -i :8000
sudo lsof -i :8501

# Stop conflicting services
sudo systemctl stop apache2  # if Apache is running
```

---

## Project Structure

```
/opt/medagent/
└── sample-deploy/
    └── MedAgent-dev-jan/
        ├── backend/
        ├── frontend/
        ├── .venv/          # Virtual environment
        ├── .env            # Environment variables
        └── requirements.txt
```

---

## Quick Reference

**Application Directory**: `/opt/medagent/sample-deploy/MedAgent-dev-jan`

**Environment File**: `/opt/medagent/sample-deploy/MedAgent-dev-jan/.env`

**Service Files**: `/etc/systemd/system/medagent-*.service`

---

That's it! Your application should now be running on EC2.
