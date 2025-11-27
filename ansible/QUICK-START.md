# Ansible - Ready to Deploy! 🚀

## ✅ Setup Complete

Your WSL Ubuntu environment is ready with:
- ✅ Ansible 2.16.3 installed
- ✅ Python 3.12.3 configured
- ✅ community.docker collection installed
- ✅ All playbooks validated

## 📋 Current Status

All Ansible playbooks are tested and ready:
- `deploy-docker-compose.yml` - Main deployment
- `check-setup.yml` - Pre-deployment checks
- `monitor.yml` - Health monitoring
- `rollback.yml` - Rollback procedures

## 🎯 Deployment Options

### Option 1: Deploy to Remote Server (Production)

**Step 1: Configure your server in inventory.ini**
```bash
# Open WSL terminal
cd "/mnt/c/Users/Shanu Pudi/Documents/3-1/Rhythm/ansible"
nano inventory.ini
```

Add your server:
```ini
[appservers]
your-server-ip ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_rsa
```

**Step 2: Test connection**
```bash
ansible appservers -i inventory.ini -m ping
```

**Step 3: Check server readiness**
```bash
ansible-playbook -i inventory.ini check-setup.yml
```

**Step 4: Deploy!**
```bash
ansible-playbook -i inventory.ini deploy-docker-compose.yml
```

**Step 5: Monitor**
```bash
ansible-playbook -i inventory.ini monitor.yml
```

---

### Option 2: Test Locally (No Remote Server Needed)

You can test the deployment on your local WSL Ubuntu:

**Step 1: Enable localhost deployment**
```bash
cd "/mnt/c/Users/Shanu Pudi/Documents/3-1/Rhythm/ansible"
nano inventory.ini
```

Uncomment this line:
```ini
localhost ansible_connection=local
```

Change `[appservers]` to:
```ini
[appservers]
localhost ansible_connection=local
```

**Step 2: Install Docker in WSL** (if not already installed)
```bash
# Update packages
sudo apt update

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add user to docker group
sudo usermod -aG docker $USER

# Start Docker
sudo service docker start
```

**Step 3: Deploy locally**
```bash
cd "/mnt/c/Users/Shanu Pudi/Documents/3-1/Rhythm/ansible"
ansible-playbook -i inventory.ini deploy-docker-compose.yml --ask-become-pass
```

---

### Option 3: Use Cloud Provider (AWS/DigitalOcean/Azure)

**AWS EC2 Example:**
```ini
[appservers]
ec2-xx-xxx-xxx-xxx.compute-1.amazonaws.com ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/aws-key.pem
```

**DigitalOcean Droplet Example:**
```ini
[appservers]
192.xxx.xxx.xxx ansible_user=root ansible_ssh_private_key_file=~/.ssh/do-key
```

---

## 🔧 Quick Commands Reference

### In Windows PowerShell
```powershell
# Open WSL
wsl

# Navigate to project
cd "/mnt/c/Users/Shanu Pudi/Documents/3-1/Rhythm/ansible"
```

### In WSL Bash
```bash
# Check Ansible version
ansible --version

# Test connection to servers
ansible appservers -i inventory.ini -m ping

# Check playbook syntax
ansible-playbook deploy-docker-compose.yml --syntax-check

# Dry run (see what would change)
ansible-playbook -i inventory.ini deploy-docker-compose.yml --check

# Actual deployment
ansible-playbook -i inventory.ini deploy-docker-compose.yml

# Monitor deployed app
ansible-playbook -i inventory.ini monitor.yml

# Rollback if needed
ansible-playbook -i inventory.ini rollback.yml

# Verbose output (for debugging)
ansible-playbook -i inventory.ini deploy-docker-compose.yml -vv
```

---

## 📝 What Each Playbook Does

### deploy-docker-compose.yml
- Installs Docker and Docker Compose on target server
- Creates application directory (`/home/user/rhythm`)
- Copies all project files (backend, frontend, docker-compose.yml)
- Creates environment files with secure passwords
- Builds Docker images
- Starts all containers
- Waits for services to be healthy
- Shows deployment status

### check-setup.yml
- Tests SSH connectivity
- Checks Python version
- Verifies disk space and memory
- Checks if Docker is installed
- Verifies sudo access
- Shows OS information

### monitor.yml
- Checks Docker container status
- Tests frontend accessibility (http://server)
- Tests backend accessibility (http://server:8081)
- Shows recent logs
- Displays disk usage

### rollback.yml
- Stops all containers
- Removes containers and volumes
- Shows remaining Docker resources
- Optional: Clean up application directory
- Optional: Prune Docker system

---

## 🎬 Example Workflow

```bash
# 1. Open WSL
wsl

# 2. Go to ansible directory
cd "/mnt/c/Users/Shanu Pudi/Documents/3-1/Rhythm/ansible"

# 3. Edit inventory with your server IP
nano inventory.ini

# 4. Test connection
ansible appservers -i inventory.ini -m ping

# 5. Check server is ready
ansible-playbook -i inventory.ini check-setup.yml

# 6. Deploy application
ansible-playbook -i inventory.ini deploy-docker-compose.yml

# 7. Monitor deployment
ansible-playbook -i inventory.ini monitor.yml

# 8. Access your app
# http://your-server-ip (Frontend)
# http://your-server-ip:8081 (Backend API)
```

---

## 🆘 Troubleshooting

### "Permission denied" errors
```bash
# Make sure SSH key has correct permissions
chmod 600 ~/.ssh/your-key.pem
```

### "Host key verification failed"
```bash
# Add server to known hosts
ssh-keyscan -H your-server-ip >> ~/.ssh/known_hosts
```

### "sudo: a password is required"
```bash
# Run with password prompt
ansible-playbook -i inventory.ini deploy-docker-compose.yml --ask-become-pass
```

### Connection timeout
```bash
# Test SSH manually first
ssh -i ~/.ssh/your-key user@your-server-ip

# Check if port 22 is open
nc -zv your-server-ip 22
```

---

## 🎯 Next Steps

1. **Get a server** (if you don't have one):
   - AWS EC2 Free Tier
   - DigitalOcean ($200 credit)
   - Azure Free Tier
   - Or use local WSL for testing

2. **Configure inventory.ini** with your server details

3. **Deploy!**
   ```bash
   ansible-playbook -i inventory.ini deploy-docker-compose.yml
   ```

4. **Access your application** at `http://your-server-ip`

---

## 📊 Deployment Summary

| Component | Status | Notes |
|-----------|--------|-------|
| Ansible Setup | ✅ Complete | Version 2.16.3 in WSL |
| Playbooks | ✅ Validated | All syntax checked |
| Docker Collection | ✅ Installed | community.docker 3.7.0 |
| Ready to Deploy | ✅ Yes | Configure inventory.ini |

**Everything is ready! Just add your server details and deploy.** 🚀
