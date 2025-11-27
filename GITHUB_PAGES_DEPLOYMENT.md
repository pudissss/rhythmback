# Rhythm Application - GitHub Pages Deployment Guide

## Overview
This guide explains how to deploy the Rhythm frontend to GitHub Pages while keeping the backend deployed elsewhere (Docker/K8s/Cloud).

## Architecture
- **Frontend**: Deployed to GitHub Pages (Static hosting)
- **Backend**: Deployed separately (Docker, Kubernetes, or Cloud provider)
- **Database**: With backend deployment

## Prerequisites
1. GitHub repository with GitHub Pages enabled
2. Backend API deployed and accessible via HTTPS
3. GitHub Actions enabled in your repository

## Step 1: Enable GitHub Pages

### Via GitHub Website
1. Go to your repository on GitHub
2. Click **Settings** → **Pages**
3. Under "Build and deployment":
   - Source: **GitHub Actions**
4. Click **Save**

## Step 2: Configure Backend API URL

### Set GitHub Secret
1. Go to **Settings** → **Secrets and variables** → **Actions**
2. Click **New repository secret**
3. Name: `VITE_BASE_API_URL`
4. Value: Your backend API URL (e.g., `https://api.rhythm-app.com`)
5. Click **Add secret**

### Alternative: Update vite.config.js
Edit `front/vite.config.js` to set a default:
```javascript
export default defineConfig({
  plugins: [react()],
  base: '/Rhythm/', // Replace with your repo name
  optimizeDeps: {
    exclude: ['lucide-react'],
  },
  define: {
    'import.meta.env.VITE_BASE_API_URL': JSON.stringify(
      process.env.VITE_BASE_API_URL || 'https://your-backend-url.com'
    )
  }
});
```

## Step 3: Update Frontend Configuration

### Update Router Base Path
Edit `front/src/App1.jsx`:
```jsx
<Router basename="/Rhythm">  {/* Add this if repo name is Rhythm */}
  <Routes>
    {/* ... */}
  </Routes>
</Router>
```

### Update Vite Config
Edit `front/vite.config.js`:
```javascript
export default defineConfig({
  plugins: [react()],
  base: '/Rhythm/', // Use your repository name
  optimizeDeps: {
    exclude: ['lucide-react'],
  }
});
```

## Step 4: Deploy

### Automatic Deployment
Every push to `main` branch triggers automatic deployment:
```powershell
git add .
git commit -m "Deploy to GitHub Pages"
git push origin main
```

### Manual Deployment
1. Go to **Actions** tab
2. Click **Deploy to GitHub Pages** workflow
3. Click **Run workflow** → **Run workflow**

### Monitor Deployment
1. Go to **Actions** tab
2. Click on the latest workflow run
3. Watch the build and deploy steps

## Step 5: Access Your Application

### Get GitHub Pages URL
Your app will be available at:
```
https://<username>.github.io/<repository-name>/
```

For example:
- `https://pudissss.github.io/Rhythm/`
- `https://pudissss.github.io/rhythmback/`

### Custom Domain (Optional)
1. Go to **Settings** → **Pages**
2. Under "Custom domain", enter your domain
3. Click **Save**
4. Configure DNS records at your domain provider:
   ```
   Type: CNAME
   Name: www (or subdomain)
   Value: <username>.github.io
   ```

## Troubleshooting

### Build Fails
```powershell
# Check the Actions tab for error details
# Common issues:
# 1. Missing dependencies
# 2. Build errors in code
# 3. Environment variables not set
```

### Blank Page After Deployment
1. Check browser console for errors
2. Verify `base` path in `vite.config.js` matches repo name
3. Check if `.nojekyll` file exists in deployment

### API Connection Issues
1. Verify backend URL is correct in GitHub Secrets
2. Check CORS configuration on backend
3. Ensure backend is accessible via HTTPS

### 404 on Page Refresh
Add to `front/public/_redirects` (for Netlify) or configure nginx:
```
/*    /index.html   200
```

For GitHub Pages, the `try_files` in nginx config handles this.

## Backend CORS Configuration

### Update Backend for GitHub Pages
Edit `back/src/main/java/com/spring/online/demo/controller/UserController.java`:

Add CORS configuration:
```java
@CrossOrigin(origins = {
    "http://localhost",
    "http://localhost:5173",
    "https://pudissss.github.io"  // Your GitHub Pages URL
})
```

Or create a global CORS config:
```java
@Configuration
public class CorsConfig {
    @Bean
    public WebMvcConfigurer corsConfigurer() {
        return new WebMvcConfigurer() {
            @Override
            public void addCorsMappings(CorsRegistry registry) {
                registry.addMapping("/**")
                    .allowedOrigins(
                        "http://localhost",
                        "http://localhost:5173",
                        "https://pudissss.github.io"
                    )
                    .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS")
                    .allowedHeaders("*")
                    .allowCredentials(true);
            }
        };
    }
}
```

## Workflow File Explanation

### `.github/workflows/github-pages.yml`
```yaml
# Triggers
on:
  push:
    branches: [ main ]  # Auto-deploy on push to main
  workflow_dispatch:    # Manual trigger

# Permissions
permissions:
  contents: read        # Read repo
  pages: write         # Write to Pages
  id-token: write      # Deploy

# Jobs
jobs:
  build:              # Build the app
    - Install Node.js
    - Install dependencies
    - Build with Vite
    - Create .nojekyll file
    - Upload build artifacts
    
  deploy:             # Deploy to Pages
    - Deploy artifacts to GitHub Pages
```

## Cost & Limits
- **Free tier**: 1 GB storage, 100 GB bandwidth/month
- **Private repos**: Requires GitHub Pro or above
- **Build time**: 20 minutes per workflow (usually 2-5 minutes for this app)

## Alternative: Deploy to Netlify/Vercel

### Netlify
```powershell
# Install Netlify CLI
npm install -g netlify-cli

# Deploy
cd front
npm run build
netlify deploy --prod --dir=dist
```

### Vercel
```powershell
# Install Vercel CLI
npm install -g vercel

# Deploy
cd front
vercel --prod
```

## Maintenance

### Update Deployment
```powershell
# Make changes
git add .
git commit -m "Update application"
git push origin main
# Automatic deployment triggered
```

### Rollback
```powershell
# View previous deployments in Actions tab
# Re-run a previous successful workflow
```

### View Logs
- **Build logs**: Actions tab → Select workflow run
- **Runtime logs**: Browser console (F12)

## Security Considerations

1. **Never commit secrets** to repository
2. Use **GitHub Secrets** for sensitive data
3. Enable **HTTPS only** in Pages settings
4. Configure **Content Security Policy** headers
5. Use **environment variables** for API URLs

## Next Steps

1. ✅ Deploy frontend to GitHub Pages
2. ✅ Deploy backend to cloud provider (AWS, Azure, GCP)
3. ✅ Configure custom domain
4. ✅ Setup SSL certificate
5. ✅ Configure CDN (CloudFlare)
6. ✅ Setup monitoring (Sentry, LogRocket)
7. ✅ Configure analytics (Google Analytics)

## Support

For issues:
1. Check **Actions** tab for build errors
2. Review **deployment logs**
3. Check **browser console** for runtime errors
4. Verify **backend connectivity**
