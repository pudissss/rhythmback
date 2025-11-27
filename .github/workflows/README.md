# GitHub Actions CI/CD Setup Guide

## 🚀 Overview

Your Rhythm app now has automated CI/CD pipelines configured:

1. **CI/CD Pipeline** (`ci-cd.yml`) - Build, test, and deploy
2. **GitHub Pages** (`github-pages.yml`) - Deploy frontend to GitHub Pages

---

## 📋 Required GitHub Secrets

### Step 1: Go to GitHub Repository Settings

Navigate to: `https://github.com/pudissss/rhythmback/settings/secrets/actions`

### Step 2: Add These Secrets

Click **"New repository secret"** for each:

#### For Docker Hub (Required for ci-cd.yml)
| Secret Name | Value | Description |
|-------------|-------|-------------|
| `DOCKER_USERNAME` | your-dockerhub-username | Your Docker Hub username |
| `DOCKER_PASSWORD` | your-dockerhub-token | Docker Hub access token or password |

**How to get Docker Hub token:**
1. Go to https://hub.docker.com/settings/security
2. Click "New Access Token"
3. Copy the token and add as `DOCKER_PASSWORD`

#### For Server Deployment (Optional - for ci-cd.yml deploy job)
| Secret Name | Value | Description |
|-------------|-------|-------------|
| `SERVER_HOST` | your.server.ip | Your server IP or domain |
| `SERVER_USER` | ubuntu | SSH username |
| `SERVER_SSH_KEY` | -----BEGIN RSA...| Your private SSH key |
| `SERVER_PORT` | 22 | SSH port (default 22) |

**How to get SSH key:**
```bash
cat ~/.ssh/id_rsa
# Copy the entire content including BEGIN and END lines
```

#### For GitHub Pages (Optional - for github-pages.yml)
| Secret Name | Value | Description |
|-------------|-------|-------------|
| `VITE_BASE_API_URL` | https://your-api.com | Backend API URL |

---

## 🔄 How the CI/CD Pipeline Works

### Workflow: `ci-cd.yml`

**Triggers:**
- Push to `main` or `develop` branch
- Pull request to `main`
- Manual workflow dispatch

**Jobs:**

### 1. **Test Job**
- ✅ Runs on every push/PR
- Executes backend tests (Maven)
- Executes frontend tests (npm)
- Uses build caching for faster runs

### 2. **Build Job** (only on main branch)
- ✅ Builds Docker images
- ✅ Pushes to Docker Hub
- ✅ Tags with `latest` and commit SHA
- ✅ Uses layer caching for faster builds

### 3. **Deploy Job** (only on main branch)
- ✅ SSH to your server
- ✅ Pull latest images
- ✅ Restart containers
- ✅ Run health checks

---

## 🌐 GitHub Pages Deployment

### Workflow: `github-pages.yml`

**What it does:**
- Builds React frontend
- Deploys to GitHub Pages
- Accessible at: `https://pudissss.github.io/rhythmback/`

**Setup:**
1. Go to: `https://github.com/pudissss/rhythmback/settings/pages`
2. Source: **GitHub Actions**
3. Wait for deployment

---

## 🎯 Usage Examples

### Push Code to Trigger CI/CD
```bash
# Make changes
git add .
git commit -m "feat: add new feature"
git push origin main

# GitHub Actions will automatically:
# 1. Run tests
# 2. Build Docker images
# 3. Push to Docker Hub
# 4. Deploy to server (if configured)
```

### View Workflow Status
```bash
# Go to: https://github.com/pudissss/rhythmback/actions
```

### Manual Trigger
1. Go to Actions tab
2. Select workflow
3. Click "Run workflow"

---

## 📊 Current Configuration

### CI/CD Pipeline Features
- ✅ Automated testing
- ✅ Docker image building
- ✅ Multi-stage builds for optimization
- ✅ Build caching (faster subsequent builds)
- ✅ SHA-based tagging
- ✅ Automated deployment
- ✅ Health checks after deployment

### GitHub Pages Features
- ✅ Automatic frontend deployment
- ✅ Production builds
- ✅ Environment variables support
- ✅ Static site hosting

---

## 🔧 Customization

### Modify Triggers
Edit `.github/workflows/ci-cd.yml`:
```yaml
on:
  push:
    branches: [ main, staging ]  # Add more branches
  schedule:
    - cron: '0 0 * * 0'  # Weekly build
```

### Skip CI for Commits
```bash
git commit -m "docs: update README [skip ci]"
```

### Add More Jobs
```yaml
jobs:
  security-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run security scan
        run: npm audit
```

---

## 🆘 Troubleshooting

### Build Fails
```bash
# Check logs in GitHub Actions tab
# Common issues:
# - Missing secrets
# - Test failures
# - Build errors
```

### Deployment Fails
```bash
# Verify secrets:
# - SERVER_HOST
# - SERVER_USER  
# - SERVER_SSH_KEY

# Test SSH manually:
ssh -i ~/.ssh/id_rsa user@server-ip
```

### Docker Push Fails
```bash
# Verify Docker Hub credentials:
# - DOCKER_USERNAME
# - DOCKER_PASSWORD (use access token)

# Test locally:
docker login -u username
docker push username/rhythm-backend:latest
```

---

## 📝 Next Steps

### 1. Add Required Secrets
```bash
# Go to GitHub repo settings → Secrets → Actions
# Add DOCKER_USERNAME and DOCKER_PASSWORD
```

### 2. Push Code
```bash
git add .
git commit -m "ci: setup GitHub Actions"
git push origin main
```

### 3. Monitor Workflow
```bash
# Watch at: https://github.com/pudissss/rhythmback/actions
```

### 4. Configure Server Deployment (Optional)
```bash
# Add SERVER_* secrets
# Setup server with Docker
# Test deployment
```

---

## 🎯 Workflow Status Badges

Add to your README.md:

```markdown
[![CI/CD Pipeline](https://github.com/pudissss/rhythmback/actions/workflows/ci-cd.yml/badge.svg)](https://github.com/pudissss/rhythmback/actions/workflows/ci-cd.yml)

[![GitHub Pages](https://github.com/pudissss/rhythmback/actions/workflows/github-pages.yml/badge.svg)](https://github.com/pudissss/rhythmback/actions/workflows/github-pages.yml)
```

---

## 📚 Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Docker Build Action](https://github.com/docker/build-push-action)
- [GitHub Pages Action](https://github.com/actions/deploy-pages)

---

## ✅ Quick Checklist

- [ ] Add Docker Hub secrets (`DOCKER_USERNAME`, `DOCKER_PASSWORD`)
- [ ] (Optional) Add server secrets for deployment
- [ ] Push code to trigger first workflow
- [ ] Check Actions tab for build status
- [ ] Enable GitHub Pages in settings
- [ ] Add workflow badges to README

**Your CI/CD pipeline is ready! Just add the secrets and push!** 🚀
