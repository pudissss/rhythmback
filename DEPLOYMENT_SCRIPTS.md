# Rhythm Deployment Scripts

## Quick Start Scripts

### deploy-docker.ps1
```powershell
# Build and deploy with Docker Compose
Write-Host "Building and deploying Rhythm with Docker..." -ForegroundColor Green

# Check if .env files exist
if (-not (Test-Path "back\.env")) {
    Write-Host "Creating back\.env from example..." -ForegroundColor Yellow
    Copy-Item "back\.env.example" "back\.env"
    Write-Host "Please edit back\.env with your actual credentials!" -ForegroundColor Red
    exit 1
}

# Build and start
docker-compose down
docker-compose build
docker-compose up -d

Write-Host "Deployment complete! Services starting..." -ForegroundColor Green
Write-Host "Waiting for services to be ready..."
Start-Sleep -Seconds 10

# Show status
docker-compose ps

Write-Host ""
Write-Host "Access your application at:" -ForegroundColor Green
Write-Host "Frontend: http://localhost" -ForegroundColor Cyan
Write-Host "Backend: http://localhost:8081" -ForegroundColor Cyan
Write-Host ""
Write-Host "View logs with: docker-compose logs -f" -ForegroundColor Yellow
```

### deploy-k8s.ps1
```powershell
# Deploy to Kubernetes
Write-Host "Deploying Rhythm to Kubernetes..." -ForegroundColor Green

# Check kubectl
try {
    kubectl version --client | Out-Null
} catch {
    Write-Host "kubectl not found! Please install kubectl." -ForegroundColor Red
    exit 1
}

# Create namespace
kubectl create namespace rhythm --dry-run=client -o yaml | kubectl apply -f -

# Deploy MySQL
Write-Host "Deploying MySQL..." -ForegroundColor Yellow
kubectl apply -f k8s/mysql-deployment.yaml

# Wait for MySQL
Write-Host "Waiting for MySQL to be ready..."
kubectl wait --for=condition=ready pod -l app=mysql -n rhythm --timeout=300s

# Deploy Backend
Write-Host "Deploying Backend..." -ForegroundColor Yellow
kubectl apply -f k8s/backend-deployment.yaml

# Wait for Backend
Write-Host "Waiting for Backend to be ready..."
kubectl wait --for=condition=ready pod -l app=backend -n rhythm --timeout=300s

# Deploy Frontend
Write-Host "Deploying Frontend..." -ForegroundColor Yellow
kubectl apply -f k8s/frontend-deployment.yaml

# Wait for Frontend
Write-Host "Waiting for Frontend to be ready..."
kubectl wait --for=condition=ready pod -l app=frontend -n rhythm --timeout=300s

Write-Host ""
Write-Host "Deployment complete!" -ForegroundColor Green
Write-Host ""
kubectl get all -n rhythm

Write-Host ""
Write-Host "Access your application:" -ForegroundColor Green
Write-Host "Run: kubectl port-forward svc/frontend 8080:80 -n rhythm" -ForegroundColor Cyan
Write-Host "Then open: http://localhost:8080" -ForegroundColor Cyan
```

### check-status.ps1
```powershell
# Check deployment status
param(
    [string]$Type = "docker"
)

Write-Host "Checking Rhythm deployment status..." -ForegroundColor Green
Write-Host ""

if ($Type -eq "docker") {
    Write-Host "=== Docker Compose Status ===" -ForegroundColor Cyan
    docker-compose ps
    Write-Host ""
    Write-Host "=== Recent Logs ===" -ForegroundColor Cyan
    docker-compose logs --tail=20
    
} elseif ($Type -eq "k8s") {
    Write-Host "=== Kubernetes Status ===" -ForegroundColor Cyan
    kubectl get all -n rhythm
    Write-Host ""
    Write-Host "=== Pod Details ===" -ForegroundColor Cyan
    kubectl get pods -n rhythm -o wide
    Write-Host ""
    Write-Host "=== Recent Events ===" -ForegroundColor Cyan
    kubectl get events -n rhythm --sort-by='.lastTimestamp' | Select-Object -Last 10
}
```

### cleanup.ps1
```powershell
# Cleanup deployment
param(
    [string]$Type = "docker"
)

Write-Host "Cleaning up Rhythm deployment..." -ForegroundColor Yellow

if ($Type -eq "docker") {
    docker-compose down -v
    Write-Host "Docker cleanup complete!" -ForegroundColor Green
    
} elseif ($Type -eq "k8s") {
    kubectl delete namespace rhythm
    Write-Host "Kubernetes cleanup complete!" -ForegroundColor Green
}
```

## Usage

### Docker Deployment
```powershell
# Deploy
.\deploy-docker.ps1

# Check status
.\check-status.ps1 -Type docker

# View logs
docker-compose logs -f

# Stop
docker-compose down
```

### Kubernetes Deployment
```powershell
# Deploy
.\deploy-k8s.ps1

# Check status
.\check-status.ps1 -Type k8s

# View logs
kubectl logs -f deployment/backend -n rhythm

# Cleanup
.\cleanup.ps1 -Type k8s
```

### Ansible Deployment
```powershell
# Update inventory first
notepad ansible\inventory.ini

# Deploy
ansible-playbook -i ansible/inventory.ini ansible/deploy-docker-compose.yml

# Check status on remote server
ssh user@server-ip "cd ~/rhythm && docker-compose ps"
```
