# AWS EC2 Deployment Guide for MedAgent

This guide will walk you through deploying the MedAgent application on an Ubuntu EC2 instance.

## Prerequisites

1. **AWS Account** with EC2 access
2. **Groq API Key** - Get one from [Groq Console](https://console.groq.com/)
3. **EC2 Key Pair** - For SSH access to your instance
4. **Basic knowledge** of AWS EC2 and Linux commands

---

## Step 1: Launch EC2 Instance

### 1.1 Create EC2 Instance

1. Log in to AWS Console
2. Navigate to **EC2 Dashboard** → **Launch Instance**
3. Configure the instance:
   - **Name**: `medagent-production` (or your preferred name)
   - **AMI**: Ubuntu Server 22.04 LTS (or latest)
   - **Instance Type**: 
     - Minimum: `t3.small` (2 vCPU, 2 GB RAM)
     - Recommended: `t3.medium` (2 vCPU, 4 GB RAM) or higher
   - **Key Pair**: Select or create a new key pair
   - **Network Settings**: 
     - Allow SSH (port 22) from your IP
     - Allow HTTP (port 80) from anywhere (0.0.0.0/0)
     - Allow HTTPS (port 443) from anywhere (0.0.0.0/0)
   - **Storage**: Minimum 20 GB (recommended: 30 GB)
   - **Security Group**: Create new or use existing

4. Click **Launch Instance**

### 1.2 Allocate Elastic IP (Optional but Recommended)

1. Go to **EC2 Dashboard** → **Elastic IPs**
2. Click **Allocate Elastic IP address**
3. Select your instance and click **Associate Elastic IP address**

This gives you a static IP address that won't change when you restart the instance.

---

## Step 2: Connect to Your EC2 Instance

### 2.1 SSH into the Instance

**Windows (PowerShell):**
```powershell
ssh -i "path/to/your-key.pem" ubuntu@<your-ec2-public-ip>
```

**Linux/macOS:**
```bash
ssh -i ~/path/to/your-key.pem ubuntu@<your-ec2-public-ip>
```

**Note**: Replace `<your-ec2-public-ip>` with your actual EC2 public IP address.

### 2.2 Update System

Once connected, update the system:
```bash
sudo apt-get update
sudo apt-get upgrade -y
```

---

## Step 3: Deploy the Application

You have two deployment options:

### Option A: Docker Deployment (Recommended)

This is the easiest and most portable method.

#### 3.1 Clone Repository on EC2

The deployment script will automatically clone the repository from GitHub. Simply run the deployment script:

```bash
# Download and run the deployment script
curl -o deploy.sh https://raw.githubusercontent.com/aisvamalar/sample-deploy/main/MedAgent-dev-jan/deploy.sh
chmod +x deploy.sh
./deploy.sh
```

**OR** if you want to clone manually first:

```bash
# On EC2 instance
cd /opt
sudo mkdir -p medagent
sudo chown $USER:$USER medagent
cd medagent
git clone https://github.com/aisvamalar/sample-deploy.git
cd sample-deploy/MedAgent-dev-jan
chmod +x deploy.sh
./deploy.sh
```

#### 3.2 Run Deployment Script

The script will automatically:
- Clone the repository from GitHub: `https://github.com/aisvamalar/sample-deploy.git`
- Navigate to the `MedAgent-dev-jan` directory
- Install all dependencies
- Set up Docker
- Configure firewall
- Build and start containers
- Set up Nginx reverse proxy

The script will:
- Install all dependencies
- Set up Docker
- Configure firewall
- Build and start containers
- Set up Nginx reverse proxy

#### 3.3 Configure Environment Variables

When prompted, edit the `.env` file:
```bash
nano /opt/medagent/sample-deploy/MedAgent-dev-jan/.env
```

Add your Groq API key:
```env
GROQ_API_KEY=your_actual_groq_api_key_here
```

Save and exit (Ctrl+X, then Y, then Enter).

#### 3.4 Verify Deployment

Check if containers are running:
```bash
docker-compose ps
```

View logs:
```bash
docker-compose logs -f
```

### Option B: Systemd Services (Without Docker)

If you prefer not to use Docker:

#### 3.1 Clone Repository on EC2

The deployment script will automatically clone the repository. Run:

```bash
# Download and run the deployment script
curl -o deploy-without-docker.sh https://raw.githubusercontent.com/aisvamalar/sample-deploy/main/MedAgent-dev-jan/deploy-without-docker.sh
chmod +x deploy-without-docker.sh
./deploy-without-docker.sh
```

**OR** clone manually:

```bash
cd /opt
sudo mkdir -p medagent
sudo chown $USER:$USER medagent
cd medagent
git clone https://github.com/aisvamalar/sample-deploy.git
cd sample-deploy/MedAgent-dev-jan
chmod +x deploy-without-docker.sh
./deploy-without-docker.sh
```

#### 3.2 Configure Environment Variables

When prompted, edit the `.env` file:
```bash
nano /opt/medagent/sample-deploy/MedAgent-dev-jan/.env
```

#### 3.4 Verify Deployment

Check service status:
```bash
sudo systemctl status medagent-backend
sudo systemctl status medagent-frontend
```

View logs:
```bash
sudo journalctl -u medagent-backend -f
sudo journalctl -u medagent-frontend -f
```

---

## Step 4: Access Your Application

Once deployed, you can access:

- **Frontend UI**: `http://<your-ec2-public-ip>` or `http://<your-ec2-public-ip>:8501`
- **Backend API**: `http://<your-ec2-public-ip>:8000`
- **API Documentation**: `http://<your-ec2-public-ip>:8000/docs`

---

## Step 5: Configure Domain Name (Optional)

### 5.1 Point Domain to EC2

1. Go to your domain registrar
2. Add an A record pointing to your EC2 Elastic IP

### 5.2 Update Nginx Configuration

Edit the Nginx config to use your domain:
```bash
sudo nano /etc/nginx/nginx.conf
```

Change:
```nginx
server_name _;
```

To:
```nginx
server_name yourdomain.com www.yourdomain.com;
```

Restart Nginx:
```bash
sudo systemctl restart nginx
```

### 5.3 Set Up SSL with Let's Encrypt (Recommended)

```bash
sudo apt-get install certbot python3-certbot-nginx
sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com
```

Certbot will automatically configure SSL and renew certificates.

---

## Step 6: Maintenance Commands

### Docker Deployment

```bash
# View logs
cd /opt/medagent/sample-deploy/MedAgent-dev-jan
docker-compose logs -f

# Restart services
docker-compose restart

# Stop services
docker-compose down

# Update application
cd /opt/medagent/sample-deploy
git pull
cd MedAgent-dev-jan
docker-compose up -d --build

# View resource usage
docker stats
```

### Systemd Deployment

```bash
# View logs
sudo journalctl -u medagent-backend -f
sudo journalctl -u medagent-frontend -f

# Restart services
sudo systemctl restart medagent-backend
sudo systemctl restart medagent-frontend

# Check status
sudo systemctl status medagent-backend medagent-frontend

# Update application
cd /opt/medagent/sample-deploy
git pull
cd MedAgent-dev-jan
source .venv/bin/activate
pip install -r requirements.txt
sudo systemctl restart medagent-backend medagent-frontend
```
```

---

## Step 7: Security Best Practices

### 7.1 Firewall Configuration

The deployment script configures UFW, but verify:
```bash
sudo ufw status
```

### 7.2 Regular Updates

Keep your system updated:
```bash
sudo apt-get update && sudo apt-get upgrade -y
```

### 7.3 Monitor Logs

Regularly check logs for errors:
```bash
# Docker
docker-compose logs --tail=100

# Systemd
sudo journalctl -u medagent-backend --since "1 hour ago"
```

### 7.4 Backup Configuration

Backup your `.env` file:
```bash
# Docker
cp /opt/medagent/sample-deploy/MedAgent-dev-jan/.env /opt/medagent/sample-deploy/MedAgent-dev-jan/.env.backup

# Systemd
sudo cp /opt/medagent/sample-deploy/MedAgent-dev-jan/.env /opt/medagent/sample-deploy/MedAgent-dev-jan/.env.backup
```

### 7.5 Set Up CloudWatch Monitoring (Optional)

1. Install CloudWatch agent:
```bash
wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
sudo dpkg -i -i ./amazon-cloudwatch-agent.deb
```

2. Configure monitoring for your application metrics

---

## Troubleshooting

### Application Not Starting

1. **Check logs**:
   ```bash
   # Docker
   docker-compose logs
   
   # Systemd
   sudo journalctl -u medagent-backend -n 50
   ```

2. **Verify environment variables**:
   ```bash
   cat .env
   ```

3. **Check port availability**:
   ```bash
   sudo netstat -tulpn | grep -E '8000|8501'
   ```

### Cannot Access from Browser

1. **Check Security Group**: Ensure ports 80, 443, 8000, 8501 are open
2. **Check Firewall**: 
   ```bash
   sudo ufw status
   ```
3. **Check if services are running**:
   ```bash
   # Docker
   docker-compose ps
   
   # Systemd
   sudo systemctl status medagent-backend medagent-frontend
   ```

### High Memory Usage

1. **Monitor resources**:
   ```bash
   # Docker
   docker stats
   
   # System
   htop
   ```

2. **Consider upgrading instance type** if consistently high

### API Timeout Issues

The Nginx configuration includes 60-second timeouts. If you need longer:
```bash
sudo nano /etc/nginx/nginx.conf
```

Increase `proxy_read_timeout` values.

---

## Cost Optimization

1. **Use Reserved Instances** for long-term deployments
2. **Set up Auto Scaling** if traffic varies
3. **Use CloudWatch alarms** to monitor costs
4. **Stop instance** when not in use (development/testing)

---

## Next Steps

- Set up automated backups
- Configure monitoring and alerting
- Set up CI/CD pipeline for automated deployments
- Implement log aggregation (CloudWatch Logs, ELK stack)
- Set up load balancing if scaling horizontally

---

## Support

For issues or questions:
1. Check application logs
2. Review AWS CloudWatch logs
3. Verify environment variables
4. Check network connectivity

---

**Deployment Date**: _______________
**EC2 Instance ID**: _______________
**Public IP**: _______________
**Domain**: _______________
