# Quick Deploy - EC2 Instance Connect (5 Minutes)

## Prerequisites
- AWS Account
- Groq API Key

---

## Step 1: Launch EC2 Instance

1. AWS Console → EC2 → **Launch Instance**
2. **AMI**: Ubuntu 22.04 LTS
3. **Instance Type**: t3.small (minimum) or t3.medium (recommended)
4. **Key Pair**: Skip (using EC2 Instance Connect)
5. **Network Settings**:
   - ✅ Allow HTTP (port 80)
   - ✅ Allow HTTPS (port 443)
   - Add Custom TCP rules:
     - Port 8000 (Backend)
     - Port 8501 (Frontend)
6. **Storage**: 20-30 GB
7. Click **Launch Instance**

---

## Step 2: Connect via EC2 Instance Connect

1. EC2 Console → **Instances** → Select your instance
2. Click **Connect** button
3. Select **EC2 Instance Connect** tab
4. Click **Connect**

Terminal opens in browser! 🎉

---

## Step 3: Deploy (Copy & Paste)

Run these commands in the EC2 Instance Connect terminal:

```bash
# Update system
sudo apt-get update && sudo apt-get upgrade -y

# Install git
sudo apt-get install -y git curl

# Clone repository
cd /opt
sudo mkdir -p medagent && sudo chown $USER:$USER medagent
cd medagent
git clone https://github.com/aisvamalar/sample-deploy.git
cd sample-deploy/MedAgent-dev-jan

# Run deployment
chmod +x deploy.sh
./deploy.sh
```

**Wait 5-10 minutes** for installation...

---

## Step 4: Configure API Key

When prompted:

```bash
nano .env
```

Replace `your_groq_api_key_here` with your actual Groq API key.

Save: `Ctrl+X`, then `Y`, then `Enter`

Restart:
```bash
docker-compose restart
```

---

## Step 5: Access Your App

Get your IP:
```bash
curl ifconfig.me
```

Open in browser:
- **Frontend**: `http://<your-ip>`
- **Backend**: `http://<your-ip>:8000`
- **API Docs**: `http://<your-ip>:8000/docs`

---

## Verify It's Working

```bash
# Check services
docker-compose ps

# Check logs
docker-compose logs -f
```

Press `Ctrl+C` to exit logs.

---

## Common Commands

```bash
# View logs
cd /opt/medagent/sample-deploy/MedAgent-dev-jan
docker-compose logs -f

# Restart
docker-compose restart

# Update
cd /opt/medagent/sample-deploy
git pull
cd MedAgent-dev-jan
docker-compose up -d --build
```

---

## Troubleshooting

**Can't access from browser?**
- Check Security Group (ports 80, 443, 8000, 8501 open)
- Check services: `docker compose ps` (or `docker-compose ps`)

**Services not starting?**
- Check logs: `docker compose logs` (or `docker-compose logs`)
- Restart: `docker compose restart`

**Python 3.11 not found error?**
- This is fixed in the updated script! Docker handles Python internally.
- If you see this, pull the latest: `git pull` and run again.

**Docker compose command not found?**
- Try: `docker compose` (plugin version)
- Or install: See `TROUBLESHOOTING.md`

**Need help?** 
- See `AWS_EC2_CONNECT_DEPLOYMENT.md` for detailed guide
- See `TROUBLESHOOTING.md` for common issues

---

✅ **Done!** Your app is live at `http://<your-ip>`
