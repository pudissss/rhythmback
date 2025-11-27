# Deploy Rhythm Application with Docker Compose
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Rhythm Application - Docker Deploy" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check Docker
Write-Host "Checking Docker..." -ForegroundColor Yellow
try {
    docker --version | Out-Null
    docker-compose --version | Out-Null
    Write-Host "✓ Docker is installed" -ForegroundColor Green
} catch {
    Write-Host "✗ Docker not found! Please install Docker Desktop." -ForegroundColor Red
    exit 1
}

# Check environment files
Write-Host ""
Write-Host "Checking environment files..." -ForegroundColor Yellow

if (-not (Test-Path "back\.env")) {
    Write-Host "! Backend .env file not found. Creating from example..." -ForegroundColor Yellow
    if (Test-Path "back\.env.example") {
        Copy-Item "back\.env.example" "back\.env"
        Write-Host ""
        Write-Host "=======================================" -ForegroundColor Red
        Write-Host "ACTION REQUIRED:" -ForegroundColor Red
        Write-Host "Please edit back\.env with your credentials:" -ForegroundColor Yellow
        Write-Host "  - MySQL password" -ForegroundColor White
        Write-Host "  - Email credentials (optional)" -ForegroundColor White
        Write-Host "=======================================" -ForegroundColor Red
        Write-Host ""
        notepad "back\.env"
        $continue = Read-Host "Have you updated the credentials? (yes/no)"
        if ($continue -ne "yes") {
            Write-Host "Deployment cancelled." -ForegroundColor Yellow
            exit 0
        }
    }
}

# Stop existing containers
Write-Host ""
Write-Host "Stopping existing containers..." -ForegroundColor Yellow
docker-compose down 2>$null

# Build images
Write-Host ""
Write-Host "Building Docker images (this may take a few minutes)..." -ForegroundColor Yellow
docker-compose build

if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ Build failed!" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Images built successfully" -ForegroundColor Green

# Start containers
Write-Host ""
Write-Host "Starting containers..." -ForegroundColor Yellow
docker-compose up -d

if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ Failed to start containers!" -ForegroundColor Red
    exit 1
}

# Wait for services
Write-Host ""
Write-Host "Waiting for services to be ready..." -ForegroundColor Yellow
Start-Sleep -Seconds 15

# Check status
Write-Host ""
Write-Host "Container Status:" -ForegroundColor Cyan
docker-compose ps

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Deployment Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Access your application:" -ForegroundColor White
Write-Host "  Frontend: http://localhost" -ForegroundColor Cyan
Write-Host "  Backend:  http://localhost:8081" -ForegroundColor Cyan
Write-Host "  MySQL:    localhost:3307" -ForegroundColor Cyan
Write-Host ""
Write-Host "Useful commands:" -ForegroundColor White
Write-Host "  View logs:    docker-compose logs -f" -ForegroundColor Yellow
Write-Host "  Stop:         docker-compose down" -ForegroundColor Yellow
Write-Host "  Restart:      docker-compose restart" -ForegroundColor Yellow
Write-Host ""
