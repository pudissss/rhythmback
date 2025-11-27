# 🚀 Rhythm Deployment - Step-by-Step Execution Guide

## ✅ Pre-Deployment Checklist

Before starting, ensure you have:
- [ ] Docker Desktop installed and running
- [ ] Git repository cloned
- [ ] All required ports available (80, 8081, 3307)
- [ ] At least 4GB RAM available
- [ ] At least 10GB disk space

## 📝 Step 1: Initial Configuration

### 1.1 Create Backend Environment File
```powershell
# Navigate to project directory
cd "C:\Users\Shanu Pudi\Documents\3-1\Rhythm"

# Copy environment template
Copy-Item back\.env.example back\.env

# Edit the file
notepad back\.env
```

**Update these values in back/.env:**
```bash
SPRING_DATASOURCE_URL=jdbc:mysql://db:3306/rhythm
SPRING_DATASOURCE_USERNAME=root
SPRING_DATASOURCE_PASSWORD=SecurePassword123!  # ⚠️ CHANGE THIS!

# Email configuration (optional for testing)
SPRING_MAIL_HOST=smtp.gmail.com
SPRING_MAIL_PORT=587
SPRING_MAIL_USERNAME=your-email@gmail.com
SPRING_MAIL_PASSWORD=your-gmail-app-password
```

### 1.2 Update docker-compose.yml Password
```powershell
notepad docker-compose.yml
```

**Find and update** (use same password as above):
```yaml
db:
  environment:
    - MYSQL_ROOT_PASSWORD=SecurePassword123!  # ⚠️ Match .env password
    
backend:
  environment:
    - SPRING_DATASOURCE_PASSWORD=SecurePassword123!  # ⚠️ Match .env password
```

---

## 🐳 Step 2: Docker Deployment (LOCAL)

### Option A: Using Deployment Script (Recommended)
```powershell
# Make sure you're in the project root
cd "C:\Users\Shanu Pudi\Documents\3-1\Rhythm"

# Run deployment script
.\deploy-docker.ps1
```

### Option B: Manual Deployment
```powershell
# 1. Clean up any existing containers
docker-compose down -v

# 2. Build images
docker-compose build

# 3. Start services
docker-compose up -d

# 4. Wait for services to start (30 seconds)
Start-Sleep -Seconds 30

# 5. Check status
docker-compose ps

# 6. View logs
docker-compose logs -f
```

### Verify Docker Deployment
```powershell
# Check all containers are running
docker-compose ps

# Expected output:
# rhythm-frontend-1   running   0.0.0.0:80->80/tcp
# rhythm-backend-1    running   0.0.0.0:8081->8081/tcp
# rhythm-db-1         running   0.0.0.0:3307->3306/tcp

# Test frontend
Start-Process http://localhost

# Test backend
curl http://localhost:8081

# Check backend logs
docker-compose logs backend | Select-Object -Last 20

# Check database
docker exec -it rhythm-db-1 mysql -u root -pSecurePassword123! -e "SHOW DATABASES;"
```

**Expected Results:**
- ✅ Frontend accessible at http://localhost
- ✅ Backend responding at http://localhost:8081
- ✅ MySQL running on port 3307
- ✅ No error messages in logs

---

## ☸️ Step 3: Kubernetes Deployment (PRODUCTION)

### 3.1 Prerequisites
```powershell
# Install kubectl (if not installed)
# Download from: https://kubernetes.io/docs/tasks/tools/

# Verify kubectl
kubectl version --client

# Check cluster connection
kubectl cluster-info
```

### 3.2 Prepare Docker Images

#### Build and Tag Images
```powershell
# Build backend
docker build -t your-dockerhub-username/rhythm-backend:latest ./back

# Build frontend
docker build -t your-dockerhub-username/rhythm-frontend:latest ./front

# Login to Docker Hub
docker login

# Push images
docker push your-dockerhub-username/rhythm-backend:latest
docker push your-dockerhub-username/rhythm-frontend:latest
```

### 3.3 Update K8s Manifests

#### Update Image References
```powershell
# Edit backend deployment
notepad k8s\backend-deployment.yaml
# Change line 16: image: your-dockerhub-username/rhythm-backend:latest

# Edit frontend deployment  
notepad k8s\frontend-deployment.yaml
# Change line 16: image: your-dockerhub-username/rhythm-frontend:latest
```

#### Update MySQL Secret
```powershell
notepad k8s\mysql-deployment.yaml
# Change line 8: mysql-root-password: YourSecurePassword123!
```

### 3.4 Deploy to Kubernetes

#### Using Deployment Script
```powershell
.\deploy-k8s.ps1
```

#### Manual Deployment
```powershell
# 1. Create namespace
kubectl create namespace rhythm

# 2. Deploy MySQL
kubectl apply -f k8s/mysql-deployment.yaml

# 3. Wait for MySQL (2-3 minutes)
kubectl wait --for=condition=ready pod -l app=mysql -n rhythm --timeout=300s

# 4. Deploy Backend
kubectl apply -f k8s/backend-deployment.yaml

# 5. Wait for Backend
kubectl wait --for=condition=ready pod -l app=backend -n rhythm --timeout=300s

# 6. Deploy Frontend
kubectl apply -f k8s/frontend-deployment.yaml

# 7. Wait for Frontend
kubectl wait --for=condition=ready pod -l app=frontend -n rhythm --timeout=300s
```

### Verify Kubernetes Deployment
```powershell
# Check all resources
kubectl get all -n rhythm

# Check pod status (all should be Running)
kubectl get pods -n rhythm

# Check logs
kubectl logs -f deployment/backend -n rhythm
kubectl logs -f deployment/frontend -n rhythm

# Access application
kubectl port-forward svc/frontend 8080:80 -n rhythm
# Then open: http://localhost:8080
```

**Expected Results:**
- ✅ All pods in Running state
- ✅ No CrashLoopBackOff errors
- ✅ Services created successfully
- ✅ Application accessible via port-forward

---

## 🤖 Step 4: Ansible Deployment (REMOTE SERVER)

### 4.1 Prerequisites
```powershell
# Install Ansible (Windows - use WSL or install via pip)
pip install ansible

# Or use WSL
wsl --install
# Then in WSL:
sudo apt update
sudo apt install ansible
```

### 4.2 Configure Server Access

#### Setup SSH Key (if not exists)
```powershell
# Generate SSH key (in WSL or Git Bash)
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa

# Copy public key to server
ssh-copy-id -i ~/.ssh/id_rsa.pub username@your-server-ip
```

#### Update Inventory
```powershell
notepad ansible\inventory.ini
```

**Replace with your details:**
```ini
[appservers]
192.168.1.100 ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_rsa

[appservers:vars]
ansible_python_interpreter=/usr/bin/python3
```

### 4.3 Update Playbook Variables
```powershell
notepad ansible\deploy-docker-compose.yml
```

**Update line 4:**
```yaml
vars:
  mysql_root_password: YourSecurePassword123!  # ⚠️ CHANGE THIS!
```

### 4.4 Test Connection
```powershell
# In WSL or Git Bash
ansible -i ansible/inventory.ini appservers -m ping

# Expected output:
# 192.168.1.100 | SUCCESS => {
#     "ping": "pong"
# }
```

### 4.5 Deploy with Ansible
```powershell
# Dry run (check mode)
ansible-playbook -i ansible/inventory.ini ansible/deploy-docker-compose.yml --check

# Actual deployment
ansible-playbook -i ansible/inventory.ini ansible/deploy-docker-compose.yml

# Verbose output
ansible-playbook -i ansible/inventory.ini ansible/deploy-docker-compose.yml -vvv
```

### Verify Ansible Deployment
```powershell
# SSH to server
ssh username@your-server-ip

# Check containers
cd ~/rhythm
docker-compose ps

# View logs
docker-compose logs -f

# Test application
curl http://localhost
```

**Expected Results:**
- ✅ Playbook runs without errors
- ✅ All containers running on remote server
- ✅ Application accessible at server IP

---

## 📄 Step 5: GitHub Pages Deployment (FRONTEND ONLY)

### 5.1 Enable GitHub Pages

1. Go to: https://github.com/pudissss/rhythmback/settings/pages
2. Under "Build and deployment":
   - Source: **GitHub Actions**
3. Click **Save**

### 5.2 Configure Backend URL Secret

1. Go to: https://github.com/pudissss/rhythmback/settings/secrets/actions
2. Click **New repository secret**
3. Name: `VITE_BASE_API_URL`
4. Value: `https://your-backend-api-url.com` (your deployed backend)
5. Click **Add secret**

### 5.3 Update Frontend for GitHub Pages

#### Update vite.config.js
```powershell
notepad front\vite.config.js
```

**Add base path:**
```javascript
export default defineConfig({
  plugins: [react()],
  base: '/rhythmback/',  // Your repo name
  optimizeDeps: {
    exclude: ['lucide-react'],
  }
});
```

#### Update Router
```powershell
notepad front\src\App1.jsx
```

**Add basename:**
```jsx
<Router basename="/rhythmback">
  <Routes>
    {/* existing routes */}
  </Routes>
</Router>
```

### 5.4 Deploy to GitHub Pages
```powershell
# Stage all changes
git add .

# Commit
git commit -m "Configure for GitHub Pages deployment"

# Push to GitHub (triggers automatic deployment)
git push origin main

# Monitor deployment
# Go to: https://github.com/pudissss/rhythmback/actions
```

### Verify GitHub Pages Deployment

1. **Wait 2-5 minutes** for deployment to complete
2. Go to Actions tab: https://github.com/pudissss/rhythmback/actions
3. Click on latest workflow run
4. Wait for green checkmark ✅
5. Access your site: https://pudissss.github.io/rhythmback/

**Expected Results:**
- ✅ Workflow completes successfully
- ✅ Site accessible at GitHub Pages URL
- ✅ Can connect to backend API

---

## 🧪 Testing Checklist

### After Each Deployment, Test:

#### 1. Frontend Access
- [ ] Landing page loads
- [ ] Animations work
- [ ] Navigation works
- [ ] No console errors

#### 2. User Authentication
- [ ] Signup form works
- [ ] Can create new user
- [ ] Login works
- [ ] Token stored correctly
- [ ] Protected routes work

#### 3. Music Features
- [ ] Songs list displays
- [ ] Can play music
- [ ] Audio controls work
- [ ] Search works
- [ ] Filters work (song/artist/movie)

#### 4. Playlist Features
- [ ] Can create playlist
- [ ] Can add songs to playlist
- [ ] Can view playlist
- [ ] Can play from playlist

#### 5. Backend API
- [ ] POST /user/signup works
- [ ] POST /user/signin works
- [ ] GET /api/playlists/user/{id} works
- [ ] POST /api/playlists/create works
- [ ] POST /api/playlists/addSong works

---

## 🔧 Quick Troubleshooting

### Issue: Port Already in Use
```powershell
# Find and kill process on port 80
netstat -ano | findstr :80
taskkill /PID <PID> /F

# Or change port in docker-compose.yml
```

### Issue: Database Connection Failed
```powershell
# Wait 30 seconds for MySQL to initialize
Start-Sleep -Seconds 30

# Restart backend
docker-compose restart backend

# Check MySQL logs
docker-compose logs db
```

### Issue: Frontend Shows Blank Page
```powershell
# Check browser console (F12)
# Common fix: Clear cache and hard reload (Ctrl+Shift+R)

# Check API URL
cat front\.env

# Rebuild frontend
docker-compose build frontend
docker-compose up -d frontend
```

### Issue: Kubernetes Pods Not Starting
```powershell
# Describe pod to see events
kubectl describe pod <pod-name> -n rhythm

# Check logs
kubectl logs <pod-name> -n rhythm

# Common fix: Pull image manually
docker pull your-registry/rhythm-backend:latest
```

---

## 📊 Deployment Status Dashboard

| Deployment Type | Status | URL | Commands |
|----------------|--------|-----|----------|
| **Docker** | ⏳ Pending | http://localhost | `.\deploy-docker.ps1` |
| **Kubernetes** | ⏳ Pending | port-forward | `.\deploy-k8s.ps1` |
| **Ansible** | ⏳ Pending | http://server-ip | `ansible-playbook...` |
| **GitHub Pages** | ⏳ Pending | https://pudissss.github.io/rhythmback/ | `git push origin main` |

**Update status after each deployment:**
- ⏳ Pending
- 🔄 In Progress  
- ✅ Success
- ❌ Failed

---

## 🎯 Next Steps After Successful Deployment

1. **Security Hardening**
   - Change all default passwords
   - Enable HTTPS
   - Configure firewall rules
   - Set up SSL certificates

2. **Monitoring Setup**
   - Configure logging
   - Set up health checks
   - Enable alerts
   - Add analytics

3. **Performance Optimization**
   - Configure caching
   - Enable CDN
   - Optimize database queries
   - Set up auto-scaling

4. **Backup & Recovery**
   - Configure database backups
   - Document rollback procedures
   - Test disaster recovery
   - Set up monitoring

---

## 📞 Support

If you encounter issues:
1. Check logs (see troubleshooting section)
2. Review documentation
3. Check GitHub Issues
4. Contact: your-email@example.com

---

**Remember**: Test each deployment method independently before moving to the next!

Good luck with your deployment! 🚀🎵
