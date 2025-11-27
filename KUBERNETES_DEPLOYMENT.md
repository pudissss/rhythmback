# Rhythm Application - Kubernetes Deployment Guide

## Prerequisites
- Kubernetes cluster (minikube, kind, or cloud provider)
- kubectl installed and configured
- Docker images pushed to a registry

## Step 1: Prepare Docker Images

### Build and Push Images
```powershell
# Build images
docker build -t your-registry/rhythm-backend:latest ./back
docker build -t your-registry/rhythm-frontend:latest ./front

# Push to registry
docker push your-registry/rhythm-backend:latest
docker push your-registry/rhythm-frontend:latest
```

### Update Image References
Edit the following files and replace `your-docker-registry/rhythm-*:latest`:
- `k8s/backend-deployment.yaml` (line 16)
- `k8s/frontend-deployment.yaml` (line 16)

## Step 2: Configure Secrets

### Update MySQL Secret
Edit `k8s/mysql-deployment.yaml` and change:
```yaml
stringData:
  mysql-root-password: your_secure_password  # Change this!
```

### Create Mail Secret (Optional)
```powershell
kubectl create secret generic mail-secret `
  --from-literal=username=your-email@gmail.com `
  --from-literal=password=your-app-password `
  -n rhythm
```

## Step 3: Deploy to Kubernetes

### Deploy in Order
```powershell
# 1. Create namespace and MySQL (with secrets)
kubectl apply -f k8s/mysql-deployment.yaml

# Wait for MySQL to be ready
kubectl wait --for=condition=ready pod -l app=mysql -n rhythm --timeout=300s

# 2. Deploy Backend
kubectl apply -f k8s/backend-deployment.yaml

# Wait for backend to be ready
kubectl wait --for=condition=ready pod -l app=backend -n rhythm --timeout=300s

# 3. Deploy Frontend
kubectl apply -f k8s/frontend-deployment.yaml

# Wait for frontend to be ready
kubectl wait --for=condition=ready pod -l app=frontend -n rhythm --timeout=300s
```

### Or Deploy All at Once
```powershell
kubectl apply -f k8s/
```

## Step 4: Verify Deployment

### Check All Resources
```powershell
kubectl get all -n rhythm
```

### Check Pod Status
```powershell
kubectl get pods -n rhythm
```

### Check Services
```powershell
kubectl get svc -n rhythm
```

### View Logs
```powershell
# Backend logs
kubectl logs -f deployment/backend -n rhythm

# Frontend logs
kubectl logs -f deployment/frontend -n rhythm

# MySQL logs
kubectl logs -f statefulset/mysql -n rhythm
```

## Step 5: Access Application

### Get Frontend Service External IP
```powershell
kubectl get svc frontend -n rhythm
```

### Port Forward (for local testing)
```powershell
# Frontend
kubectl port-forward svc/frontend 8080:80 -n rhythm

# Backend
kubectl port-forward svc/backend 8081:8081 -n rhythm

# MySQL
kubectl port-forward svc/mysql 3306:3306 -n rhythm
```

Then access:
- Frontend: http://localhost:8080
- Backend: http://localhost:8081

## Troubleshooting

### Check Pod Events
```powershell
kubectl describe pod <pod-name> -n rhythm
```

### View Persistent Volumes
```powershell
kubectl get pv
kubectl get pvc -n rhythm
```

### Check Secrets
```powershell
kubectl get secrets -n rhythm
```

### Restart Deployment
```powershell
kubectl rollout restart deployment/backend -n rhythm
kubectl rollout restart deployment/frontend -n rhythm
```

### Scale Replicas
```powershell
# Scale up
kubectl scale deployment/backend --replicas=3 -n rhythm

# Scale down
kubectl scale deployment/backend --replicas=1 -n rhythm
```

## Clean Up

### Delete All Resources
```powershell
kubectl delete namespace rhythm
```

### Delete Specific Resources
```powershell
kubectl delete -f k8s/frontend-deployment.yaml
kubectl delete -f k8s/backend-deployment.yaml
kubectl delete -f k8s/mysql-deployment.yaml
```

## Monitoring

### Watch Pod Status
```powershell
kubectl get pods -n rhythm -w
```

### Resource Usage
```powershell
kubectl top pods -n rhythm
kubectl top nodes
```

### Get Deployment Status
```powershell
kubectl rollout status deployment/backend -n rhythm
kubectl rollout status deployment/frontend -n rhythm
```
