# Minikube Setup Script for Windows
# Run this script in PowerShell as Administrator

Write-Host "=== Minikube Setup ===" -ForegroundColor Green

# Check if Chocolatey is installed
if (!(Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Chocolatey..." -ForegroundColor Yellow
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}

# Install Minikube
Write-Host "Installing Minikube..." -ForegroundColor Yellow
choco install minikube -y

# Start Minikube with Docker driver
Write-Host "Starting Minikube cluster..." -ForegroundColor Yellow
minikube start --driver=docker --memory=4096 --cpus=2

# Verify installation
Write-Host "`n=== Cluster Info ===" -ForegroundColor Green
kubectl cluster-info

Write-Host "`n=== Ready for deployment! ===" -ForegroundColor Green
