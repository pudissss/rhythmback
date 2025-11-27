# Ansible Setup for Windows

## Important Note
Ansible **control node** cannot run natively on Windows. You have 3 options:

## Option 1: WSL (Windows Subsystem for Linux) - RECOMMENDED

### Install WSL
```powershell
# Run in PowerShell as Administrator
wsl --install -d Ubuntu
# Restart your computer
```

### Setup Ansible in WSL
```bash
# Open Ubuntu (WSL)
sudo apt update
sudo apt install ansible -y

# Install Docker collection
ansible-galaxy collection install community.docker

# Verify installation
ansible --version
```

### Use Ansible from WSL
```bash
# Navigate to your project
cd /mnt/c/Users/Shanu\ Pudi/Documents/3-1/Rhythm/ansible

# Test connection
ansible appservers -i inventory.ini -m ping

# Deploy
ansible-playbook -i inventory.ini deploy-docker-compose.yml
```

---

## Option 2: Docker Container

### Run Ansible in Docker
```powershell
# Pull Ansible Docker image
docker pull willhallonline/ansible:latest

# Run Ansible commands
docker run --rm -it `
  -v ${PWD}:/ansible `
  -v ~/.ssh:/root/.ssh:ro `
  willhallonline/ansible:latest `
  ansible-playbook -i inventory.ini deploy-docker-compose.yml
```

### Create helper script
Save as `run-ansible.ps1`:
```powershell
param(
    [Parameter(Mandatory=$true)]
    [string]$Command
)

docker run --rm -it `
  -v ${PWD}:/ansible `
  -v $env:USERPROFILE\.ssh:/root/.ssh:ro `
  willhallonline/ansible:latest `
  $Command
```

Usage:
```powershell
.\run-ansible.ps1 "ansible-playbook -i inventory.ini deploy-docker-compose.yml"
```

---

## Option 3: Remote Control Node

Use a Linux machine (cloud VM, local VM, or another computer) as the Ansible control node.

### Setup on Linux Control Node
```bash
# Install Ansible
sudo apt update
sudo apt install ansible -y

# Copy project files
scp -r ansible/ user@control-node:/path/to/rhythm/

# SSH to control node and run
ssh user@control-node
cd /path/to/rhythm/ansible
ansible-playbook -i inventory.ini deploy-docker-compose.yml
```

---

## Quick Test (No Installation Required)

You can test the deployment using SSH and Docker commands manually:

```powershell
# SSH to your server
ssh user@your-server-ip

# Run these commands manually
sudo apt update
sudo apt install docker.io docker-compose -y
sudo systemctl start docker
sudo usermod -aG docker $USER

# Create app directory
mkdir -p ~/rhythm
cd ~/rhythm

# Copy files (from your local machine)
# Use scp, rsync, or git clone

# Create .env file
cat > .env << EOF
MYSQL_ROOT_PASSWORD=Rhythm@2024Secure
MYSQL_DATABASE=rhythm
MYSQL_USER=rhythm_user
MYSQL_PASSWORD=Rhythm@2024Secure
EOF

# Run docker-compose
docker-compose up -d

# Check status
docker-compose ps
```

---

## Recommended Approach for Your Setup

**Use WSL with Ansible** - It's the most native experience on Windows.

### Complete WSL Setup

1. **Install WSL**
   ```powershell
   wsl --install
   ```

2. **Open Ubuntu and install Ansible**
   ```bash
   sudo apt update && sudo apt upgrade -y
   sudo apt install ansible python3-pip -y
   ansible-galaxy collection install community.docker
   ```

3. **Access your project**
   ```bash
   cd /mnt/c/Users/"Shanu Pudi"/Documents/3-1/Rhythm/ansible
   ```

4. **Setup SSH key** (if needed)
   ```bash
   ssh-keygen -t rsa -b 4096
   ssh-copy-id user@your-server-ip
   ```

5. **Edit inventory.ini**
   ```bash
   nano inventory.ini
   # Add your server details
   ```

6. **Test and deploy**
   ```bash
   # Test connection
   ansible appservers -i inventory.ini -m ping
   
   # Check server setup
   ansible-playbook -i inventory.ini check-setup.yml
   
   # Deploy application
   ansible-playbook -i inventory.ini deploy-docker-compose.yml
   ```

---

## What to Do Next

1. Choose your preferred option (WSL recommended)
2. Set up Ansible following the instructions above
3. Configure your server details in `inventory.ini`
4. Run the check playbook to verify everything
5. Deploy your application!

---

## Files Created

```
ansible/
├── README.md                  # Complete deployment guide
├── WINDOWS-SETUP.md          # This file
├── inventory.ini             # Server configuration
├── deploy-docker-compose.yml # Main deployment playbook
├── check-setup.yml           # Verify server setup
├── monitor.yml               # Monitor application
└── rollback.yml              # Rollback deployment
```

---

## Need Help?

If you don't have a remote server yet, you can:
- Use **AWS EC2 Free Tier** (12 months free)
- Use **DigitalOcean** ($200 free credit for 60 days)
- Use **Azure** or **Google Cloud** free tiers
- Use local **VirtualBox** VM for testing

Let me know which option you'd like to proceed with!
