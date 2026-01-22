# Quick EC2 Deployment Instructions

## Repository
**GitHub URL**: https://github.com/aisvamalar/sample-deploy.git

## One-Command Deployment

After connecting to your EC2 instance via SSH, run:

```bash
curl -sSL https://raw.githubusercontent.com/aisvamalar/sample-deploy/main/MedAgent-dev-jan/deploy.sh | bash
```

## Manual Deployment Steps

### 1. Connect to EC2
```bash
ssh -i "your-key.pem" ubuntu@<ec2-ip>
```

### 2. Clone Repository
```bash
cd /opt
sudo mkdir -p medagent
sudo chown $USER:$USER medagent
cd medagent
git clone https://github.com/aisvamalar/sample-deploy.git
cd sample-deploy/MedAgent-dev-jan
```

### 3. Run Deployment Script
```bash
chmod +x deploy.sh
./deploy.sh
```

### 4. Configure Environment
When prompted, add your Groq API key:
```bash
nano .env
# Add: GROQ_API_KEY=your_actual_key_here
```

### 5. Access Application
- Frontend: `http://<ec2-ip>`
- Backend: `http://<ec2-ip>:8000`
- API Docs: `http://<ec2-ip>:8000/docs`

## Update Application
```bash
cd /opt/medagent/sample-deploy
git pull
cd MedAgent-dev-jan
docker-compose up -d --build
```

## View Logs
```bash
cd /opt/medagent/sample-deploy/MedAgent-dev-jan
docker-compose logs -f
```
