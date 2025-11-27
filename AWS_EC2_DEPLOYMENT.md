# AWS EC2 Deployment Guide for Rhythm App

## Step 1: Launch EC2 Instance

1. **Login to AWS Console**: https://console.aws.amazon.com/ec2
2. **Launch Instance**:
   - Click "Launch Instance"
   - Name: `rhythm-app-server`
   - AMI: **Ubuntu Server 22.04 LTS** (Free tier eligible)
   - Instance type: **t2.micro** (Free tier) or **t2.small** (better performance)
   - Key pair: Create new or use existing (download `.pem` file - YOU NEED THIS!)

3. **Network Settings**:
   - Create security group with these rules:
     - SSH: Port 22 (Your IP or 0.0.0.0/0)
     - HTTP: Port 80 (0.0.0.0/0)
     - Custom TCP: Port 8081 (0.0.0.0/0) - Backend API
     - Custom TCP: Port 3306 (0.0.0.0/0) - MySQL (optional, for external access)

4. **Storage**: 8-20 GB (default is fine)
5. **Launch** and wait for instance to start

## Step 2: Connect to EC2 and Install Docker

### Connect via SSH:
```powershell
# Set proper permissions on .pem file
icacls "your-key.pem" /inheritance:r
icacls "your-key.pem" /grant:r "%USERNAME%:R"

# Connect to EC2
ssh -i "your-key.pem" ubuntu@YOUR_EC2_PUBLIC_IP
```

### Install Docker:
```bash
# Update system
sudo apt update
sudo apt upgrade -y

# Install Docker
sudo apt install docker.io docker-compose -y

# Start Docker
sudo systemctl start docker
sudo systemctl enable docker

# Add ubuntu user to docker group
sudo usermod -aG docker ubuntu

# Logout and login again for group to take effect
exit
```

### Reconnect and verify:
```bash
ssh -i "your-key.pem" ubuntu@YOUR_EC2_PUBLIC_IP
docker --version
docker-compose --version
```

## Step 3: Setup Application Directory

```bash
# Create app directory
mkdir -p ~/rhythm
cd ~/rhythm

# Create docker-compose.yml
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  mysql:
    image: mysql:8.0
    container_name: rhythm-mysql
    environment:
      MYSQL_ROOT_PASSWORD: rootpassword
      MYSQL_DATABASE: rhythmdb
    ports:
      - "3306:3306"
    volumes:
      - mysql_data:/var/lib/mysql
    restart: always

  backend:
    image: YOUR_DOCKERHUB_USERNAME/rhythm-backend:latest
    container_name: rhythm-backend
    environment:
      SPRING_DATASOURCE_URL: jdbc:mysql://mysql:3306/rhythmdb
      SPRING_DATASOURCE_USERNAME: root
      SPRING_DATASOURCE_PASSWORD: rootpassword
    ports:
      - "8081:8081"
    depends_on:
      - mysql
    restart: always

  frontend:
    image: YOUR_DOCKERHUB_USERNAME/rhythm-frontend:latest
    container_name: rhythm-frontend
    ports:
      - "80:80"
    depends_on:
      - backend
    restart: always

volumes:
  mysql_data:
EOF

# Replace YOUR_DOCKERHUB_USERNAME with your actual Docker Hub username
nano docker-compose.yml  # or use vim
```

## Step 4: Configure GitHub Secrets

1. Go to: https://github.com/pudissss/rhythmback/settings/secrets/actions
2. Click "New repository secret"
3. Add these secrets:

### SERVER_HOST
- Name: `SERVER_HOST`
- Value: Your EC2 public IP (e.g., `54.123.45.67`)

### SERVER_USER
- Name: `SERVER_USER`
- Value: `ubuntu`

### SERVER_SSH_KEY
- Name: `SERVER_SSH_KEY`
- Value: Full content of your `.pem` file
  ```
  -----BEGIN RSA PRIVATE KEY-----
  MIIEpAIBAAKCAQEA...
  (entire content of your .pem file)
  ...
  -----END RSA PRIVATE KEY-----
  ```

### SERVER_PORT (optional)
- Name: `SERVER_PORT`
- Value: `22`

## Step 5: Enable Deployment in GitHub Actions

The workflow is currently disabled. Once secrets are added, uncomment the deploy job in `.github/workflows/ci-cd.yml`

## Step 6: Test Deployment

1. Push a commit to main branch
2. GitHub Actions will:
   - Run tests
   - Build Docker images
   - Push to Docker Hub
   - Deploy to EC2 via SSH
   - Run docker-compose up on EC2

3. Access your app:
   - Frontend: `http://YOUR_EC2_PUBLIC_IP`
   - Backend: `http://YOUR_EC2_PUBLIC_IP:8081`

## Troubleshooting

### Can't connect to EC2?
- Check security group allows SSH from your IP
- Verify .pem file permissions
- Use correct username (ubuntu for Ubuntu, ec2-user for Amazon Linux)

### Docker permission denied?
```bash
sudo usermod -aG docker ubuntu
# Logout and login again
```

### Port already in use?
```bash
sudo netstat -tulpn | grep :80
sudo docker-compose down
```

### Check logs on EC2:
```bash
cd ~/rhythm
docker-compose logs -f
docker-compose ps
```

## Cost Estimate

- **t2.micro** (Free tier): $0/month for 750 hours
- **t2.small**: ~$17/month
- Data transfer: First 100GB/month free

## Security Best Practices

1. Restrict SSH to your IP only in security group
2. Use strong MySQL passwords
3. Enable AWS CloudWatch for monitoring
4. Regular backups using AWS snapshots
5. Consider using AWS RDS for MySQL (managed service)
