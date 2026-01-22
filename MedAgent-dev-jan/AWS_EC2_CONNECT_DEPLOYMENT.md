# AWS EC2 Deployment Guide - Using EC2 Instance Connect

This guide walks you through deploying MedAgent on AWS EC2 using **EC2 Instance Connect** (browser-based SSH - no local SSH keys needed).

---

## Prerequisites

- ✅ AWS Account with EC2 access
- ✅ Groq API Key ([Get one here](https://console.groq.com/))
- ✅ Basic knowledge of AWS Console

---

## Step 1: Launch EC2 Instance

### 1.1 Navigate to EC2 Dashboard

1. Log in to [AWS Console](https://console.aws.amazon.com/)
2. Search for **EC2** in the search bar
3. Click on **EC2** service

### 1.2 Launch Instance

1. Click **"Launch Instance"** button (orange button)
2. Configure the instance:

#### **Name and Tags**
- **Name**: `medagent-production` (or your preferred name)

#### **Application and OS Images (AMI)**
- Select **Ubuntu Server 22.04 LTS** (or latest Ubuntu LTS)
- Architecture: **64-bit (x86)**

#### **Instance Type**
- **Minimum**: `t3.small` (2 vCPU, 2 GB RAM) - ~$0.0208/hour
- **Recommended**: `t3.medium` (2 vCPU, 4 GB RAM) - ~$0.0416/hour
- For production: `t3.large` or higher

#### **Key Pair (Login)**
- **IMPORTANT**: You can skip this if using EC2 Instance Connect
- Or create a new key pair if you want SSH access later
- Click **"Create new key pair"** if needed
  - Name: `medagent-key`
  - Key pair type: RSA
  - Private key file format: `.pem`
  - Click **"Create key pair"** and download it

#### **Network Settings**
- **Allow SSH traffic from**: 
  - Select **"My IP"** (for security)
  - Or **"Anywhere (0.0.0.0/0)"** if using EC2 Instance Connect only
- **Allow HTTP traffic from the internet**: ✅ Check this box
- **Allow HTTPS traffic from the internet**: ✅ Check this box
- Click **"Edit"** to add custom rules:
  - **Type**: Custom TCP
  - **Port**: 8000
  - **Source**: 0.0.0.0/0 (for Backend API)
  - **Type**: Custom TCP
  - **Port**: 8501
  - **Source**: 0.0.0.0/0 (for Frontend)

#### **Configure Storage**
- **Size**: 20 GB (minimum) or 30 GB (recommended)
- **Volume Type**: gp3 (default)

#### **Advanced Details** (Optional)
- You can leave defaults

3. Click **"Launch Instance"** (orange button at bottom)

### 1.3 Wait for Instance to Start

1. Click **"View all instances"** or go to **Instances** in left sidebar
2. Wait for **Instance State** to show **"Running"** (green)
3. Wait for **Status Checks** to show **"2/2 checks passed"** (green)
4. Note your **Public IPv4 address** (e.g., `54.123.45.67`)

---

## Step 2: Connect Using EC2 Instance Connect

### 2.1 Open EC2 Instance Connect

1. In the **Instances** list, select your instance (check the box)
2. Click **"Connect"** button at the top
3. Select **"EC2 Instance Connect"** tab
4. Click **"Connect"** button

A new browser tab will open with a terminal session connected to your EC2 instance.

### 2.2 Verify Connection

You should see a terminal prompt like:
```bash
ubuntu@ip-172-31-XX-XX:~$
```

---

## Step 3: Deploy the Application

### 3.1 Update System Packages

In the EC2 Instance Connect terminal, run:

```bash
sudo apt-get update
sudo apt-get upgrade -y
```

### 3.2 Install Git (if not already installed)

```bash
sudo apt-get install -y git curl
```

### 3.3 Clone Repository and Navigate

```bash
cd /opt
sudo mkdir -p medagent
sudo chown $USER:$USER medagent
cd medagent
git clone https://github.com/aisvamalar/sample-deploy.git
cd sample-deploy/MedAgent-dev-jan
```

### 3.4 Run Deployment Script

```bash
chmod +x deploy.sh
./deploy.sh
```

The script will:
- Install Docker, Docker Compose, Nginx, and other dependencies
- Configure firewall
- Build Docker containers
- Start all services

**This will take 5-10 minutes** - be patient!

### 3.5 Configure Environment Variables

When the script prompts you, you need to add your Groq API key:

```bash
nano .env
```

In the editor:
1. Find the line: `GROQ_API_KEY=your_groq_api_key_here`
2. Replace `your_groq_api_key_here` with your actual Groq API key
3. Press `Ctrl + X` to exit
4. Press `Y` to save
5. Press `Enter` to confirm

**Example:**
```env
GROQ_API_KEY=gsk_your_actual_api_key_here_123456789
```

### 3.6 Restart Services (if needed)

After editing `.env`, restart the containers:

```bash
docker-compose down
docker-compose up -d
```

---

## Step 4: Verify Deployment

### 4.1 Check Service Status

```bash
docker-compose ps
```

You should see three services running:
- `medagent-backend` (status: Up)
- `medagent-frontend` (status: Up)
- `medagent-nginx` (status: Up)

### 4.2 Check Logs

```bash
docker-compose logs -f
```

Press `Ctrl + C` to exit logs view.

### 4.3 Test Health Endpoint

```bash
curl http://localhost:8000/health
```

Should return: `{"status":"healthy","service":"medagent-backend"}`

---

## Step 5: Access Your Application

### 5.1 Get Your Public IP

In the EC2 Instance Connect terminal:

```bash
curl ifconfig.me
```

Or check in AWS Console: **Instances** → Your instance → **Public IPv4 address**

### 5.2 Access URLs

Open these URLs in your browser (replace `<your-ec2-ip>` with your actual IP):

- **Frontend UI**: `http://<your-ec2-ip>`
- **Backend API**: `http://<your-ec2-ip>:8000`
- **API Documentation**: `http://<your-ec2-ip>:8000/docs`
- **Health Check**: `http://<your-ec2-ip>:8000/health`

**Example:**
- Frontend: `http://54.123.45.67`
- Backend: `http://54.123.45.67:8000`
- API Docs: `http://54.123.45.67:8000/docs`

---

## Step 6: (Optional) Set Up Domain Name

### 6.1 Point Domain to EC2

1. Go to your domain registrar (GoDaddy, Namecheap, etc.)
2. Add an **A Record**:
   - **Name**: `@` (or `www`)
   - **Type**: A
   - **Value**: Your EC2 Public IP
   - **TTL**: 3600

### 6.2 Update Nginx Configuration

In EC2 Instance Connect:

```bash
cd /opt/medagent/sample-deploy/MedAgent-dev-jan
sudo nano nginx.conf
```

Change:
```nginx
server_name _;
```

To:
```nginx
server_name yourdomain.com www.yourdomain.com;
```

Save and restart:
```bash
docker-compose restart nginx
```

### 6.3 Set Up SSL with Let's Encrypt (Recommended)

```bash
sudo apt-get install -y certbot
sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com
```

Follow the prompts. Certbot will automatically configure SSL.

---

## Step 7: Useful Commands

### View Logs

```bash
cd /opt/medagent/sample-deploy/MedAgent-dev-jan
docker-compose logs -f
```

### View Specific Service Logs

```bash
docker-compose logs -f backend
docker-compose logs -f frontend
docker-compose logs -f nginx
```

### Restart Services

```bash
docker-compose restart
```

### Stop Services

```bash
docker-compose down
```

### Start Services

```bash
docker-compose up -d
```

### Update Application

```bash
cd /opt/medagent/sample-deploy
git pull
cd MedAgent-dev-jan
docker-compose up -d --build
```

### Check Resource Usage

```bash
docker stats
```

### Check Disk Space

```bash
df -h
```

---

## Troubleshooting

### Services Not Starting

**Check logs:**
```bash
docker-compose logs
```

**Check if ports are in use:**
```bash
sudo netstat -tulpn | grep -E '8000|8501|80'
```

**Restart Docker:**
```bash
sudo systemctl restart docker
docker-compose up -d
```

### Cannot Access from Browser

1. **Check Security Group:**
   - Go to EC2 Console → Your Instance → Security tab
   - Click on Security Group
   - Ensure rules allow:
     - Port 80 (HTTP) from 0.0.0.0/0
     - Port 443 (HTTPS) from 0.0.0.0/0
     - Port 8000 (Backend) from 0.0.0.0/0
     - Port 8501 (Frontend) from 0.0.0.0/0

2. **Check Firewall:**
   ```bash
   sudo ufw status
   ```

3. **Check if services are running:**
   ```bash
   docker-compose ps
   ```

### API Key Not Working

1. **Verify .env file:**
   ```bash
   cat /opt/medagent/sample-deploy/MedAgent-dev-jan/.env
   ```

2. **Restart services after editing .env:**
   ```bash
   docker-compose restart
   ```

### High Memory Usage

**Check memory:**
```bash
free -h
docker stats
```

**If memory is low, consider:**
- Upgrading instance type (t3.small → t3.medium)
- Stopping unused containers
- Restarting services

### Connection Timeout

**Increase Nginx timeouts:**
```bash
cd /opt/medagent/sample-deploy/MedAgent-dev-jan
sudo nano nginx.conf
```

Increase `proxy_read_timeout` values (default is 60s).

---

## Security Best Practices

### 1. Restrict Security Group

- Only allow SSH (port 22) from your IP
- Keep HTTP/HTTPS open for public access
- Consider using AWS WAF for additional protection

### 2. Regular Updates

```bash
sudo apt-get update && sudo apt-get upgrade -y
cd /opt/medagent/sample-deploy
git pull
cd MedAgent-dev-jan
docker-compose up -d --build
```

### 3. Monitor Logs

Regularly check logs for errors:
```bash
docker-compose logs --tail=100
```

### 4. Backup Configuration

```bash
cp /opt/medagent/sample-deploy/MedAgent-dev-jan/.env /opt/medagent/sample-deploy/MedAgent-dev-jan/.env.backup
```

### 5. Set Up CloudWatch Monitoring (Optional)

1. Install CloudWatch agent
2. Configure monitoring for CPU, memory, disk
3. Set up alarms for high usage

---

## Cost Optimization

### Estimated Monthly Costs

- **t3.small**: ~$15/month (if running 24/7)
- **t3.medium**: ~$30/month (if running 24/7)
- **Data Transfer**: First 100 GB free, then $0.09/GB
- **Storage (30 GB)**: ~$3/month

### Tips to Reduce Costs

1. **Stop instance when not in use:**
   - EC2 Console → Instance → Instance State → Stop
   - You only pay for storage when stopped

2. **Use Reserved Instances** for long-term deployments (save up to 75%)

3. **Use Spot Instances** for development/testing (save up to 90%)

4. **Monitor usage** with AWS Cost Explorer

---

## Quick Reference

### Deployment Checklist

- [ ] EC2 instance launched and running
- [ ] Security group configured (ports 80, 443, 8000, 8501)
- [ ] Connected via EC2 Instance Connect
- [ ] Repository cloned
- [ ] Deployment script executed
- [ ] `.env` file configured with Groq API key
- [ ] Services running (`docker-compose ps`)
- [ ] Application accessible via browser
- [ ] (Optional) Domain name configured
- [ ] (Optional) SSL certificate installed

### Important Paths

- **Application Directory**: `/opt/medagent/sample-deploy/MedAgent-dev-jan`
- **Environment File**: `/opt/medagent/sample-deploy/MedAgent-dev-jan/.env`
- **Docker Compose**: `/opt/medagent/sample-deploy/MedAgent-dev-jan/docker-compose.yml`

### Support

If you encounter issues:
1. Check the logs: `docker-compose logs`
2. Verify security group settings
3. Check firewall: `sudo ufw status`
4. Review this guide's troubleshooting section

---

## Next Steps

- ✅ Set up automated backups
- ✅ Configure monitoring and alerting
- ✅ Set up CI/CD pipeline
- ✅ Implement log aggregation
- ✅ Set up load balancing (if scaling)

---

**Deployment Date**: _______________  
**EC2 Instance ID**: _______________  
**Public IP**: _______________  
**Domain**: _______________
