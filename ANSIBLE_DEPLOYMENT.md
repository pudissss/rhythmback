# Rhythm Application - Ansible Deployment Guide

## Prerequisites
- Ansible installed on your local machine
- SSH access to target server(s)
- SSH key configured for passwordless authentication
- Target server: Ubuntu 20.04+ or similar Linux distribution

## Step 1: Setup Ansible

### Install Ansible (if not already installed)
```powershell
# Windows (using WSL or Python)
pip install ansible

# Or using Windows Subsystem for Linux (WSL)
sudo apt update
sudo apt install ansible
```

## Step 2: Configure Inventory

### Edit `ansible/inventory.ini`
```ini
[appservers]
192.168.1.100 ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_rsa

[appservers:vars]
ansible_python_interpreter=/usr/bin/python3
```

Replace:
- `192.168.1.100` with your server IP
- `ubuntu` with your SSH username
- `~/.ssh/id_rsa` with your SSH key path

### Test Connection
```powershell
ansible -i ansible/inventory.ini appservers -m ping
```

## Step 3: Update Variables

### Edit `ansible/deploy-docker-compose.yml`
Update the variables section:
```yaml
vars:
  app_dir: /home/{{ ansible_user }}/rhythm
  mysql_root_password: your_secure_password  # Change this!
```

## Step 4: Run Deployment

### Dry Run (Check Mode)
```powershell
ansible-playbook -i ansible/inventory.ini ansible/deploy-docker-compose.yml --check
```

### Full Deployment
```powershell
ansible-playbook -i ansible/inventory.ini ansible/deploy-docker-compose.yml
```

### Verbose Output
```powershell
ansible-playbook -i ansible/inventory.ini ansible/deploy-docker-compose.yml -vvv
```

## Step 5: Verify Deployment

### Check Service Status
```powershell
# SSH to server
ssh user@your-server-ip

# Check running containers
cd ~/rhythm
docker-compose ps

# Check logs
docker-compose logs -f
```

### Test Application
- Frontend: http://your-server-ip
- Backend: http://your-server-ip:8081

## Common Tasks

### Update Application
```powershell
# Re-run the playbook
ansible-playbook -i ansible/inventory.ini ansible/deploy-docker-compose.yml
```

### Stop Application
```powershell
ansible appservers -i ansible/inventory.ini -b -m shell -a "cd /home/ubuntu/rhythm && docker-compose down"
```

### Start Application
```powershell
ansible appservers -i ansible/inventory.ini -b -m shell -a "cd /home/ubuntu/rhythm && docker-compose up -d"
```

### View Logs
```powershell
ansible appservers -i ansible/inventory.ini -b -m shell -a "cd /home/ubuntu/rhythm && docker-compose logs --tail=100"
```

### Restart Specific Service
```powershell
ansible appservers -i ansible/inventory.ini -b -m shell -a "cd /home/ubuntu/rhythm && docker-compose restart backend"
```

## Troubleshooting

### Connection Issues
```powershell
# Test SSH connection
ssh -i ~/.ssh/id_rsa user@server-ip

# Verify Ansible can connect
ansible -i ansible/inventory.ini appservers -m ping -vvv
```

### Permission Issues
```powershell
# Ensure SSH key has correct permissions
chmod 600 ~/.ssh/id_rsa

# Test sudo access on remote server
ansible appservers -i ansible/inventory.ini -b -m shell -a "whoami"
```

### Docker Issues on Remote Server
```powershell
# Check Docker service
ansible appservers -i ansible/inventory.ini -b -m service -a "name=docker state=started"

# Check Docker version
ansible appservers -i ansible/inventory.ini -b -m shell -a "docker --version"
```

### Playbook Errors
```powershell
# Run with syntax check
ansible-playbook ansible/deploy-docker-compose.yml --syntax-check

# Run step by step
ansible-playbook -i ansible/inventory.ini ansible/deploy-docker-compose.yml --step
```

## Advanced Configuration

### Multiple Servers
Edit `ansible/inventory.ini`:
```ini
[appservers]
server1 ansible_host=192.168.1.100 ansible_user=ubuntu
server2 ansible_host=192.168.1.101 ansible_user=ubuntu

[appservers:vars]
ansible_python_interpreter=/usr/bin/python3
```

### Use Ansible Vault for Secrets
```powershell
# Create encrypted vault file
ansible-vault create ansible/secrets.yml

# Add to playbook:
# vars_files:
#   - secrets.yml

# Run playbook with vault password
ansible-playbook -i ansible/inventory.ini ansible/deploy-docker-compose.yml --ask-vault-pass
```

## Clean Up

### Remove Application
```powershell
ansible appservers -i ansible/inventory.ini -b -m shell -a "cd /home/ubuntu/rhythm && docker-compose down -v"
ansible appservers -i ansible/inventory.ini -b -m file -a "path=/home/ubuntu/rhythm state=absent"
```
