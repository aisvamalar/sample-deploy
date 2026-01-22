# Quick Start - EC2 Deployment

## 5-Minute Deployment

### 1. Connect to EC2
- AWS Console → EC2 → Instances → Connect → EC2 Instance Connect

### 2. Clone and Deploy
```bash
sudo apt-get update
sudo apt-get install -y git curl
sudo mkdir -p /opt/medagent && sudo chown $USER:$USER /opt/medagent
cd /opt/medagent
git clone https://github.com/aisvamalar/sample-deploy.git
cd sample-deploy/MedAgent-dev-jan
chmod +x deploy-without-docker.sh
./deploy-without-docker.sh
```

### 3. Add API Key
When prompted:
```bash
nano .env
```
Replace `your_groq_api_key_here` with your actual key.
Save: `Ctrl+X`, `Y`, `Enter`

### 4. Restart Services
```bash
sudo systemctl restart medagent-backend medagent-frontend
```

### 5. Access Your App
```bash
curl ifconfig.me  # Get your IP
```
- Frontend: `http://<your-ip>:8501`
- Backend: `http://<your-ip>:8000`

Done! 🎉
