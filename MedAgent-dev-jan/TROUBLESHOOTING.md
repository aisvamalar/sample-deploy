# Troubleshooting Guide

## Common Deployment Issues

### Issue: Python 3.11 Not Found

**Error:**
```
E: Unable to locate package python3.11
```

**Solution:**
The Docker deployment script no longer requires Python on the host system. If you see this error, you're using an old version of the script. The updated script uses Docker which handles Python internally.

**For non-Docker deployment:**
The script now uses the default Python 3.10 that comes with Ubuntu 22.04, which is compatible with the application.

---

### Issue: Docker Compose Command Not Found

**Error:**
```
docker-compose: command not found
```

**Solution:**
Ubuntu 22.04 uses Docker Compose as a plugin. Use one of these:

```bash
# Try plugin version (recommended)
docker compose version

# If that works, use:
docker compose up -d
docker compose logs -f

# If plugin doesn't work, install standalone:
sudo curl -L "https://github.com/docker/compose/releases/download/v2.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

---

### Issue: Permission Denied for Docker

**Error:**
```
permission denied while trying to connect to the Docker daemon socket
```

**Solution:**
```bash
# Add user to docker group
sudo usermod -aG docker $USER

# Log out and log back in, or run:
newgrp docker

# Verify:
docker ps
```

---

### Issue: Port Already in Use

**Error:**
```
Error: bind: address already in use
```

**Solution:**
```bash
# Check what's using the port
sudo netstat -tulpn | grep -E '8000|8501|80'

# Stop existing containers
docker compose down

# Or kill the process
sudo kill -9 <PID>
```

---

### Issue: Cannot Access Application from Browser

**Checklist:**
1. **Security Group Settings:**
   - EC2 Console → Instances → Your Instance → Security tab
   - Ensure ports 80, 443, 8000, 8501 are open to 0.0.0.0/0

2. **Firewall (UFW):**
   ```bash
   sudo ufw status
   sudo ufw allow 80/tcp
   sudo ufw allow 443/tcp
   sudo ufw allow 8000/tcp
   sudo ufw allow 8501/tcp
   ```

3. **Services Running:**
   ```bash
   docker compose ps
   # All services should show "Up"
   ```

4. **Check Logs:**
   ```bash
   docker compose logs
   ```

---

### Issue: API Key Not Working

**Symptoms:**
- Application starts but API calls fail
- Error messages about API key

**Solution:**
```bash
# Verify .env file exists and has correct key
cat /opt/medagent/sample-deploy/MedAgent-dev-jan/.env

# Edit if needed
nano /opt/medagent/sample-deploy/MedAgent-dev-jan/.env

# Restart services
docker compose restart
```

---

### Issue: Out of Memory

**Error:**
```
Cannot allocate memory
```

**Solution:**
1. **Check memory:**
   ```bash
   free -h
   docker stats
   ```

2. **Upgrade instance:**
   - Stop instance
   - Change instance type (t3.small → t3.medium)
   - Start instance

3. **Or add swap:**
   ```bash
   sudo fallocate -l 2G /swapfile
   sudo chmod 600 /swapfile
   sudo mkswap /swapfile
   sudo swapon /swapfile
   ```

---

### Issue: Git Clone Fails

**Error:**
```
fatal: unable to access 'https://github.com/...'
```

**Solution:**
```bash
# Check internet connectivity
ping -c 3 8.8.8.8

# Try again
git clone https://github.com/aisvamalar/sample-deploy.git
```

---

### Issue: Docker Build Fails

**Error:**
```
ERROR: failed to solve: failed to fetch
```

**Solution:**
```bash
# Clean Docker cache
docker system prune -a

# Try building again
docker compose build --no-cache
```

---

### Issue: Nginx Not Starting

**Error:**
```
nginx: [emerg] bind() to 0.0.0.0:80 failed (98: Address already in use)
```

**Solution:**
```bash
# Check what's using port 80
sudo lsof -i :80

# Stop Apache if running
sudo systemctl stop apache2
sudo systemctl disable apache2

# Restart nginx
docker compose restart nginx
```

---

### Issue: Script Exits Early (set -e)

**Error:**
Script stops at first error

**Solution:**
The script uses `set -e` to exit on errors. Check the error message and fix the issue. Common causes:
- Package not found (already fixed in updated script)
- Permission denied
- Network issues

**To continue despite errors (not recommended):**
Remove `set -e` from the script, but better to fix the root cause.

---

## Getting Help

1. **Check logs:**
   ```bash
   docker compose logs --tail=100
   ```

2. **Check service status:**
   ```bash
   docker compose ps
   systemctl status docker
   ```

3. **Verify configuration:**
   ```bash
   cat .env
   docker compose config
   ```

4. **Review deployment guide:**
   - See `AWS_EC2_CONNECT_DEPLOYMENT.md` for detailed steps

---

## Quick Fixes

### Restart Everything
```bash
cd /opt/medagent/sample-deploy/MedAgent-dev-jan
docker compose down
docker compose up -d
```

### Clean Start
```bash
cd /opt/medagent/sample-deploy/MedAgent-dev-jan
docker compose down -v
docker compose build --no-cache
docker compose up -d
```

### View All Logs
```bash
docker compose logs -f --tail=50
```

### Check Resource Usage
```bash
docker stats
df -h
free -h
```
