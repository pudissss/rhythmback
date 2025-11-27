# Ansible Deployment Guide for Rhythm Music App

## Prerequisites

### On Your Local Machine (Control Node)
1. **Install Ansible**
   ```bash
   # Windows (via WSL or Git Bash)
   pip install ansible
   
   # Or via package manager
   sudo apt-get install ansible  # Ubuntu/Debian
   brew install ansible          # macOS
   ```

2. **Install required collections**
   ```bash
   ansible-galaxy collection install community.docker
   ```

3. **SSH Key Setup**
   ```bash
   # Generate SSH key if you don't have one
   ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
   
   # Copy to remote server
   ssh-copy-id user@your-server-ip
   ```

### On Remote Server (Target Node)
- Ubuntu 20.04+ / Debian 10+ / CentOS 7+
- SSH access with sudo privileges
- Python 3 installed
- At least 4GB RAM, 20GB disk space
- Ports 80, 8081, 3307 available

---

## Quick Start

### 1. Configure Inventory

Edit `inventory.ini`:
```ini
[appservers]
# Replace with your server details
192.168.1.100 ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_rsa

# Or for multiple servers
server1.example.com ansible_user=deploy
server2.example.com ansible_user=deploy

[appservers:vars]
ansible_python_interpreter=/usr/bin/python3
```

### 2. Test Connection
```bash
cd ansible
ansible appservers -i inventory.ini -m ping
```

Expected output:
```
192.168.1.100 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

### 3. Deploy Application
```bash
# Dry run (check mode)
ansible-playbook -i inventory.ini deploy-docker-compose.yml --check

# Actual deployment
ansible-playbook -i inventory.ini deploy-docker-compose.yml

# With verbose output
ansible-playbook -i inventory.ini deploy-docker-compose.yml -vv
```

---

## Configuration Files

### inventory.ini
Defines target servers and connection details.

### deploy-docker-compose.yml
Main playbook that:
- Installs Docker and Docker Compose
- Creates application directory
- Copies application files
- Sets up environment variables
- Builds and runs containers
- Verifies deployment

---

## Customization

### Change Passwords
Edit `deploy-docker-compose.yml`:
```yaml
vars:
  mysql_root_password: YourSecurePassword123!
  mysql_user: rhythm_user
  mysql_password: YourSecurePassword123!
  mysql_database: rhythm
```

### Change Application Directory
```yaml
vars:
  app_dir: /opt/rhythm  # Default: /home/{{ ansible_user }}/rhythm
```

### Target Specific Servers
```bash
# Deploy to specific host
ansible-playbook -i inventory.ini deploy-docker-compose.yml --limit server1.example.com

# Deploy to group
ansible-playbook -i inventory.ini deploy-docker-compose.yml --limit appservers
```

---

## Advanced Usage

### Deploy with Tags
```bash
# Only install Docker
ansible-playbook -i inventory.ini deploy-docker-compose.yml --tags install

# Only deploy application
ansible-playbook -i inventory.ini deploy-docker-compose.yml --tags deploy
```

### Override Variables
```bash
ansible-playbook -i inventory.ini deploy-docker-compose.yml \
  -e "mysql_root_password=CustomPassword123" \
  -e "app_dir=/custom/path"
```

### Use Ansible Vault for Secrets
```bash
# Create encrypted file
ansible-vault create secrets.yml

# Add to secrets.yml:
mysql_root_password: SecurePassword123
mysql_password: SecurePassword123

# Deploy with vault
ansible-playbook -i inventory.ini deploy-docker-compose.yml --ask-vault-pass
```

---

## Troubleshooting

### Connection Issues
```bash
# Test SSH connection
ssh -i ~/.ssh/id_rsa user@server-ip

# Check Ansible connectivity with verbose
ansible appservers -i inventory.ini -m ping -vvv
```

### Permission Issues
```bash
# Ensure user has sudo access
ansible appservers -i inventory.ini -m shell -a "sudo -l"

# Run with different user
ansible-playbook -i inventory.ini deploy-docker-compose.yml -u root
```

### Docker Installation Fails
```bash
# Manually install Docker on server
ssh user@server-ip
sudo apt-get update
sudo apt-get install docker.io docker-compose
```

### Check Deployment Status
```bash
# SSH to server and check
ssh user@server-ip
cd ~/rhythm
docker-compose ps
docker-compose logs
```

---

## Post-Deployment

### Access Application
```
http://your-server-ip           # Frontend
http://your-server-ip:8081      # Backend API
```

### Monitor Logs
```bash
# From control node
ansible appservers -i inventory.ini -m shell -a "cd ~/rhythm && docker-compose logs --tail=50"

# Or SSH to server
ssh user@server-ip
cd ~/rhythm
docker-compose logs -f
```

### Update Application
```bash
# Just re-run the playbook
ansible-playbook -i inventory.ini deploy-docker-compose.yml
```

### Rollback
```bash
# SSH to server
cd ~/rhythm
docker-compose down
# Restore previous code/config
docker-compose up -d
```

---

## Security Best Practices

1. **Use Ansible Vault** for sensitive data
2. **Limit SSH access** - use key-based auth only
3. **Configure firewall** on remote server
4. **Use non-root user** for deployment
5. **Regular updates** - keep packages updated
6. **HTTPS/SSL** - set up reverse proxy with SSL

---

## Example Workflow

```bash
# 1. Update code locally
cd /path/to/rhythm
git pull

# 2. Test locally
docker-compose up -d

# 3. Deploy to staging
ansible-playbook -i inventory.ini deploy-docker-compose.yml --limit staging

# 4. Deploy to production
ansible-playbook -i inventory.ini deploy-docker-compose.yml --limit production
```

---

## Support

For issues:
1. Check logs: `ansible-playbook ... -vv`
2. Verify server access: `ansible appservers -m ping`
3. Check Docker status on server: `docker-compose ps`
4. Review application logs: `docker-compose logs`
