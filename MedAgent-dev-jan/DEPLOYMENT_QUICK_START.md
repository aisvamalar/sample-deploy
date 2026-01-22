# Quick Start Deployment Guide

## Prerequisites Checklist
- [ ] AWS EC2 instance running Ubuntu 22.04 LTS
- [ ] EC2 Security Group allows: SSH (22), HTTP (80), HTTPS (443)
- [ ] Groq API Key ready
- [ ] SSH access to EC2 instance

## Quick Deployment (5 minutes)

### 1. Connect to EC2
```bash
ssh -i "your-key.pem" ubuntu@<ec2-ip>
```

### 2. Clone Repository and Run Deployment
The deployment script will automatically clone from GitHub. Run:

```bash
# Download deployment script
curl -o deploy.sh https://raw.githubusercontent.com/aisvamalar/sample-deploy/main/MedAgent-dev-jan/deploy.sh
chmod +x deploy.sh
./deploy.sh
```

**OR** clone manually first:

```bash
cd /opt
sudo mkdir -p medagent && sudo chown $USER:$USER medagent
cd medagent
git clone https://github.com/aisvamalar/sample-deploy.git
cd sample-deploy/MedAgent-dev-jan
chmod +x deploy.sh
./deploy.sh
```

### 3. Configure API Key
When prompted, edit the `.env` file:
```bash
nano /opt/medagent/sample-deploy/MedAgent-dev-jan/.env
```
Add: `GROQ_API_KEY=your_actual_key_here`

### 5. Access Application
- Frontend: `http://<ec2-ip>`
- Backend API: `http://<ec2-ip>:8000`
- API Docs: `http://<ec2-ip>:8000/docs`

## Common Commands

### View Logs
```bash
cd /opt/medagent/sample-deploy/MedAgent-dev-jan
docker-compose logs -f
```

### Restart Services
```bash
docker-compose restart
```

### Stop Services
```bash
docker-compose down
```

### Update Application
```bash
cd /opt/medagent/sample-deploy
git pull
cd MedAgent-dev-jan
docker-compose up -d --build
```

## Troubleshooting

**Services not starting?**
```bash
docker-compose logs
```

**Can't access from browser?**
- Check Security Group rules
- Check firewall: `sudo ufw status`
- Verify services: `docker-compose ps`

**Need help?** See `AWS_DEPLOYMENT.md` for detailed guide.
