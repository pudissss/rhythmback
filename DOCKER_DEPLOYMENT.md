# Rhythm Application - Docker Deployment Guide

## Prerequisites
- Docker and Docker Compose installed
- Ports 80, 8081, and 3307 available
- At least 4GB RAM available

## Environment Setup

### 1. Create Backend Environment File
Create `back/.env` with your actual credentials:
```bash
SPRING_DATASOURCE_URL=jdbc:mysql://db:3306/rhythm
SPRING_DATASOURCE_USERNAME=root
SPRING_DATASOURCE_PASSWORD=your_secure_password
SPRING_MAIL_HOST=smtp.gmail.com
SPRING_MAIL_PORT=587
SPRING_MAIL_USERNAME=your_email@gmail.com
SPRING_MAIL_PASSWORD=your_gmail_app_password
```

### 2. Update docker-compose.yml
Replace `your_password` with your actual MySQL password

## Build and Run

### Option 1: Build and Start All Services
```powershell
docker-compose up --build -d
```

### Option 2: Build Images Separately
```powershell
# Build backend
docker-compose build backend

# Build frontend
docker-compose build frontend

# Start all services
docker-compose up -d
```

## Verify Deployment

### Check Running Containers
```powershell
docker-compose ps
```

### Check Logs
```powershell
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f backend
docker-compose logs -f frontend
docker-compose logs -f db
```

### Test Services
- Frontend: http://localhost
- Backend API: http://localhost:8081
- MySQL: localhost:3307

## Troubleshooting

### Database Connection Issues
```powershell
# Wait for MySQL to be ready
docker-compose exec db mysqladmin ping -h localhost -u root -p

# Create database if needed
docker-compose exec db mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS rhythm;"
```

### Backend Not Starting
```powershell
# Check backend logs
docker-compose logs backend

# Restart backend
docker-compose restart backend
```

### Frontend Build Issues
```powershell
# Rebuild frontend
docker-compose build --no-cache frontend
```

## Stop and Clean Up

### Stop All Services
```powershell
docker-compose down
```

### Stop and Remove Volumes (Clean Database)
```powershell
docker-compose down -v
```

### Remove All Images
```powershell
docker-compose down --rmi all
```
