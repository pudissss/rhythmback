# 🎵 Rhythm Application - Complete Deployment Guide

## 📋 Table of Contents
1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Quick Start](#quick-start)
4. [Deployment Options](#deployment-options)
5. [Configuration](#configuration)
6. [Testing](#testing)
7. [Troubleshooting](#troubleshooting)

## Overview

Rhythm is a full-stack music streaming application with multiple deployment options:
- **Docker Compose**: Local development and testing
- **Kubernetes**: Production-grade orchestration
- **Ansible**: Automated server deployment
- **GitHub Pages**: Static frontend hosting

## Prerequisites

### Required Software
- **Docker & Docker Compose**: [Install Docker Desktop](https://www.docker.com/products/docker-desktop)
- **Node.js 18+**: [Download Node.js](https://nodejs.org/)
- **Java 17**: [Download OpenJDK 17](https://adoptium.net/)
- **Git**: [Install Git](https://git-scm.com/)

### Optional (based on deployment method)
- **Kubernetes (kubectl)**: For K8s deployment
- **Ansible**: For automated server deployment
- **GitHub Account**: For GitHub Pages deployment

## Quick Start

### 1️⃣ Clone Repository
```powershell
git clone https://github.com/pudissss/rhythmback.git
cd rhythmback
```

### 2️⃣ Configure Environment
```powershell
# Copy environment template
Copy-Item back\.env.example back\.env

# Edit with your credentials
notepad back\.env
```

### 3️⃣ Deploy with Docker
```powershell
# Run deployment script
.\deploy-docker.ps1

# Or manually
docker-compose up --build -d
```

### 4️⃣ Access Application
- **Frontend**: http://localhost
- **Backend**: http://localhost:8081
- **MySQL**: localhost:3307

## Deployment Options

### 🐳 Option 1: Docker Compose (Recommended for Development)

**Best for**: Local development, testing, quick demos

```powershell
# Deploy
.\deploy-docker.ps1

# Or step by step
docker-compose build
docker-compose up -d
docker-compose ps
```

**Detailed Guide**: [DOCKER_DEPLOYMENT.md](DOCKER_DEPLOYMENT.md)

**Pros**:
- ✅ Quick setup (5 minutes)
- ✅ All services in one command
- ✅ Easy to debug
- ✅ Works on any OS

**Cons**:
- ❌ Not production-grade
- ❌ No auto-scaling
- ❌ Single-machine only

---

### ☸️ Option 2: Kubernetes (Recommended for Production)

**Best for**: Production deployments, high availability, scaling

```powershell
# Deploy
.\deploy-k8s.ps1

# Or step by step
kubectl apply -f k8s/mysql-deployment.yaml
kubectl apply -f k8s/backend-deployment.yaml
kubectl apply -f k8s/frontend-deployment.yaml
```

**Detailed Guide**: [KUBERNETES_DEPLOYMENT.md](KUBERNETES_DEPLOYMENT.md)

**Pros**:
- ✅ Production-ready
- ✅ Auto-scaling
- ✅ Self-healing
- ✅ Rolling updates
- ✅ Load balancing

**Cons**:
- ❌ Complex setup
- ❌ Requires cluster
- ❌ Steeper learning curve

---

### 🤖 Option 3: Ansible (Recommended for Server Deployment)

**Best for**: Deploying to remote servers, infrastructure as code

```powershell
# Update inventory
notepad ansible\inventory.ini

# Deploy
ansible-playbook -i ansible/inventory.ini ansible/deploy-docker-compose.yml
```

**Detailed Guide**: [ANSIBLE_DEPLOYMENT.md](ANSIBLE_DEPLOYMENT.md)

**Pros**:
- ✅ Automated deployment
- ✅ Repeatable
- ✅ Multiple servers
- ✅ Infrastructure as code

**Cons**:
- ❌ Requires SSH access
- ❌ Server setup needed
- ❌ Ansible knowledge required

---

### 📄 Option 4: GitHub Pages (Frontend Only)

**Best for**: Free frontend hosting, static site deployment

```powershell
# Push to GitHub (auto-deploys)
git add .
git commit -m "Deploy to GitHub Pages"
git push origin main
```

**Detailed Guide**: [GITHUB_PAGES_DEPLOYMENT.md](GITHUB_PAGES_DEPLOYMENT.md)

**Pros**:
- ✅ Free hosting
- ✅ Auto-deployment
- ✅ CDN included
- ✅ HTTPS by default

**Cons**:
- ❌ Frontend only
- ❌ Backend needed separately
- ❌ Static content only

---

## Configuration

### Backend Configuration

#### Environment Variables (back/.env)
```bash
# Database
SPRING_DATASOURCE_URL=jdbc:mysql://db:3306/rhythm
SPRING_DATASOURCE_USERNAME=root
SPRING_DATASOURCE_PASSWORD=your_secure_password

# Email (optional)
SPRING_MAIL_HOST=smtp.gmail.com
SPRING_MAIL_PORT=587
SPRING_MAIL_USERNAME=your-email@gmail.com
SPRING_MAIL_PASSWORD=your-app-password
```

### Frontend Configuration

#### Environment Variables (front/.env)
```bash
VITE_BASE_API_URL=http://localhost:8081
```

#### For Production
```bash
VITE_BASE_API_URL=https://your-production-api.com
```

### Docker Configuration

#### docker-compose.yml
Key settings:
- **Frontend Port**: 80
- **Backend Port**: 8081
- **MySQL Port**: 3307 (to avoid conflict with local MySQL)
- **MySQL Password**: Change in docker-compose.yml

### Kubernetes Configuration

#### Image Registry
Update in k8s files:
- `k8s/backend-deployment.yaml`: Line 16
- `k8s/frontend-deployment.yaml`: Line 16

```yaml
image: your-registry/rhythm-backend:latest
```

#### Secrets
Update MySQL password in `k8s/mysql-deployment.yaml`:
```yaml
stringData:
  mysql-root-password: your_secure_password
```

## Testing

### Local Testing

#### Test Backend
```powershell
# Health check
curl http://localhost:8081/user/signin

# Test signup
Invoke-WebRequest -Uri http://localhost:8081/user/signup `
  -Method POST `
  -ContentType "application/json" `
  -Body '{"username":"test","email":"test@test.com","password":"test123","role":"USER"}'
```

#### Test Frontend
```powershell
# Open in browser
Start-Process http://localhost

# Or
Start-Process http://localhost:5173  # Vite dev server
```

#### Test Database
```powershell
# Connect to MySQL
docker exec -it rhythm-db-1 mysql -u root -p

# Show databases
SHOW DATABASES;
USE rhythm;
SHOW TABLES;
```

### End-to-End Testing

1. ✅ **Signup**: Create new user
2. ✅ **Login**: Login with credentials
3. ✅ **Browse Songs**: View song catalog
4. ✅ **Play Music**: Play a song
5. ✅ **Create Playlist**: Create new playlist
6. ✅ **Add to Playlist**: Add songs to playlist
7. ✅ **View Playlist**: View playlist contents

## Troubleshooting

### Common Issues

#### 🔴 "Port already in use"
```powershell
# Stop conflicting services
docker-compose down

# Or change ports in docker-compose.yml
ports:
  - "8080:80"  # Changed from 80:80
```

#### 🔴 "Connection refused" to backend
```powershell
# Check backend logs
docker-compose logs backend

# Verify backend is running
docker-compose ps

# Test backend health
curl http://localhost:8081
```

#### 🔴 "Database connection failed"
```powershell
# Wait for MySQL to initialize (first time takes ~30 seconds)
docker-compose logs db

# Restart backend
docker-compose restart backend
```

#### 🔴 Frontend shows blank page
```powershell
# Check browser console (F12)
# Verify API URL in .env
# Check CORS settings in backend
```

### Logs

#### Docker Compose
```powershell
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f backend
docker-compose logs -f frontend
docker-compose logs -f db
```

#### Kubernetes
```powershell
# Pod logs
kubectl logs -f deployment/backend -n rhythm

# Events
kubectl get events -n rhythm

# Describe pod
kubectl describe pod <pod-name> -n rhythm
```

### Health Checks

```powershell
# Backend
curl http://localhost:8081

# Frontend
curl http://localhost

# MySQL
docker exec -it rhythm-db-1 mysqladmin ping -u root -p
```

## Deployment Scripts

### PowerShell Scripts
- `deploy-docker.ps1` - Deploy with Docker Compose
- `deploy-k8s.ps1` - Deploy to Kubernetes
- Scripts automatically check prerequisites and provide helpful output

### Manual Commands
See [DEPLOYMENT_SCRIPTS.md](DEPLOYMENT_SCRIPTS.md) for all commands

## Production Checklist

Before deploying to production:

### Security
- [ ] Change all default passwords
- [ ] Use strong MySQL password
- [ ] Set up SSL/TLS certificates
- [ ] Configure firewall rules
- [ ] Enable HTTPS only
- [ ] Review CORS settings
- [ ] Use secrets management (not .env files)

### Performance
- [ ] Enable database backups
- [ ] Configure persistent volumes (K8s)
- [ ] Set up monitoring (Prometheus, Grafana)
- [ ] Configure logging (ELK stack)
- [ ] Set up CDN for frontend
- [ ] Enable caching

### Reliability
- [ ] Set up health checks
- [ ] Configure auto-scaling
- [ ] Set up load balancer
- [ ] Enable backup/restore procedures
- [ ] Configure alerting
- [ ] Document rollback procedures

## Support

### Documentation
- [Docker Deployment](DOCKER_DEPLOYMENT.md)
- [Kubernetes Deployment](KUBERNETES_DEPLOYMENT.md)
- [Ansible Deployment](ANSIBLE_DEPLOYMENT.md)
- [GitHub Pages Deployment](GITHUB_PAGES_DEPLOYMENT.md)
- [Deployment Scripts](DEPLOYMENT_SCRIPTS.md)

### Getting Help
1. Check logs first (see Troubleshooting section)
2. Review documentation
3. Check GitHub Issues
4. Contact support

## Contributing

Contributions welcome! Please:
1. Fork the repository
2. Create feature branch
3. Test deployments
4. Submit pull request

## License

[Add your license here]

---

Made with ❤️ by Shanu Pudi
