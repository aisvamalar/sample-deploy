# Deployment Summary - Git-Based EC2 Deployment

## Repository Information
- **GitHub URL**: https://github.com/aisvamalar/sample-deploy.git
- **Project Directory**: `MedAgent-dev-jan/` (inside the cloned repository)

## Quick Deployment

### Step 1: Connect to EC2
```bash
ssh -i "your-key.pem" ubuntu@<ec2-ip>
```

### Step 2: Run Deployment Script
The script will automatically clone from GitHub:

```bash
# Option 1: Direct download and run
curl -sSL https://raw.githubusercontent.com/aisvamalar/sample-deploy/main/MedAgent-dev-jan/deploy.sh | bash

# Option 2: Manual clone and run
cd /opt
sudo mkdir -p medagent && sudo chown $USER:$USER medagent
cd medagent
git clone https://github.com/aisvamalar/sample-deploy.git
cd sample-deploy/MedAgent-dev-jan
chmod +x deploy.sh
./deploy.sh
```

### Step 3: Configure Environment
```bash
nano /opt/medagent/sample-deploy/MedAgent-dev-jan/.env
# Add: GROQ_API_KEY=your_actual_key_here
```

### Step 4: Access Application
- **Frontend**: `http://<ec2-ip>`
- **Backend API**: `http://<ec2-ip>:8000`
- **API Docs**: `http://<ec2-ip>:8000/docs`

## Project Structure on EC2
```
/opt/medagent/
└── sample-deploy/
    └── MedAgent-dev-jan/
        ├── backend/
        ├── frontend/
        ├── docker-compose.yml
        ├── Dockerfile
        ├── .env
        └── ...
```

## Common Commands

### View Logs
```bash
cd /opt/medagent/sample-deploy/MedAgent-dev-jan
docker-compose logs -f
```

### Update Application
```bash
cd /opt/medagent/sample-deploy
git pull
cd MedAgent-dev-jan
docker-compose up -d --build
```

### Restart Services
```bash
cd /opt/medagent/sample-deploy/MedAgent-dev-jan
docker-compose restart
```

### Stop Services
```bash
cd /opt/medagent/sample-deploy/MedAgent-dev-jan
docker-compose down
```

## Files Updated for Git Deployment

✅ **deploy.sh** - Now clones from GitHub automatically  
✅ **deploy-without-docker.sh** - Updated for Git cloning  
✅ **systemd/medagent-backend.service** - Updated paths  
✅ **systemd/medagent-frontend.service** - Updated paths  
✅ **AWS_DEPLOYMENT.md** - Updated documentation  
✅ **DEPLOYMENT_QUICK_START.md** - Updated quick guide  

## Notes

- The deployment script automatically handles Git cloning
- All paths are configured for `/opt/medagent/sample-deploy/MedAgent-dev-jan/`
- The script checks if the repository already exists and pulls updates if needed
- Environment variables are configured in `.env` file
