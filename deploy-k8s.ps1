# Deploy Rhythm Application to Kubernetes
param(
    [string]$ImageTag = "latest",
    [string]$Registry = "your-registry"
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Rhythm - Kubernetes Deployment" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check kubectl
Write-Host "Checking kubectl..." -ForegroundColor Yellow
try {
    kubectl version --client --short
    Write-Host "✓ kubectl is installed" -ForegroundColor Green
} catch {
    Write-Host "✗ kubectl not found! Please install kubectl." -ForegroundColor Red
    Write-Host "Download from: https://kubernetes.io/docs/tasks/tools/" -ForegroundColor Yellow
    exit 1
}

# Check cluster connection
Write-Host ""
Write-Host "Checking cluster connection..." -ForegroundColor Yellow
try {
    kubectl cluster-info | Out-Null
    Write-Host "✓ Connected to Kubernetes cluster" -ForegroundColor Green
} catch {
    Write-Host "✗ Cannot connect to cluster!" -ForegroundColor Red
    exit 1
}

# Create/Update namespace
Write-Host ""
Write-Host "Creating namespace 'rhythm'..." -ForegroundColor Yellow
kubectl create namespace rhythm --dry-run=client -o yaml | kubectl apply -f -

# Deploy MySQL
Write-Host ""
Write-Host "Deploying MySQL StatefulSet..." -ForegroundColor Yellow
kubectl apply -f k8s/mysql-deployment.yaml

Write-Host "Waiting for MySQL to be ready (this may take a minute)..."
kubectl wait --for=condition=ready pod -l app=mysql -n rhythm --timeout=300s

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ MySQL is ready" -ForegroundColor Green
} else {
    Write-Host "✗ MySQL failed to start" -ForegroundColor Red
    Write-Host "Check logs with: kubectl logs -l app=mysql -n rhythm" -ForegroundColor Yellow
    exit 1
}

# Deploy Backend
Write-Host ""
Write-Host "Deploying Backend..." -ForegroundColor Yellow
kubectl apply -f k8s/backend-deployment.yaml

Write-Host "Waiting for Backend to be ready..."
kubectl wait --for=condition=ready pod -l app=backend -n rhythm --timeout=300s

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Backend is ready" -ForegroundColor Green
} else {
    Write-Host "✗ Backend failed to start" -ForegroundColor Red
    Write-Host "Check logs with: kubectl logs -l app=backend -n rhythm" -ForegroundColor Yellow
}

# Deploy Frontend
Write-Host ""
Write-Host "Deploying Frontend..." -ForegroundColor Yellow
kubectl apply -f k8s/frontend-deployment.yaml

Write-Host "Waiting for Frontend to be ready..."
kubectl wait --for=condition=ready pod -l app=frontend -n rhythm --timeout=300s

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Frontend is ready" -ForegroundColor Green
} else {
    Write-Host "✗ Frontend failed to start" -ForegroundColor Red
    Write-Host "Check logs with: kubectl logs -l app=frontend -n rhythm" -ForegroundColor Yellow
}

# Display status
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Deployment Status" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
kubectl get all -n rhythm

# Get service info
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Access Information" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "To access the application locally:" -ForegroundColor White
Write-Host ""
Write-Host "1. Frontend (port 8080):" -ForegroundColor Cyan
Write-Host "   kubectl port-forward svc/frontend 8080:80 -n rhythm" -ForegroundColor Yellow
Write-Host "   Then open: http://localhost:8080" -ForegroundColor White
Write-Host ""
Write-Host "2. Backend (port 8081):" -ForegroundColor Cyan
Write-Host "   kubectl port-forward svc/backend 8081:8081 -n rhythm" -ForegroundColor Yellow
Write-Host "   Then access: http://localhost:8081" -ForegroundColor White
Write-Host ""
Write-Host "3. MySQL (port 3306):" -ForegroundColor Cyan
Write-Host "   kubectl port-forward svc/mysql 3306:3306 -n rhythm" -ForegroundColor Yellow
Write-Host ""
Write-Host "Useful commands:" -ForegroundColor White
Write-Host "  View pods:    kubectl get pods -n rhythm" -ForegroundColor Yellow
Write-Host "  View logs:    kubectl logs -f deployment/backend -n rhythm" -ForegroundColor Yellow
Write-Host "  Delete all:   kubectl delete namespace rhythm" -ForegroundColor Yellow
Write-Host ""
