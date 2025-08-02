# 🚀 Frontend Deployment Guide - Azure Static Web Apps

## Overview
Your Azure Practice Exam Platform frontend will be deployed using Azure Static Web Apps, providing:
- ✅ **Zero Cost** - Free tier for personal projects
- ✅ **Built-in CI/CD** - Automatic deployments from GitHub
- ✅ **Custom Domains** - Free SSL certificates
- ✅ **Global CDN** - Fast content delivery worldwide

## Files Created

### 1. ARM Template with Static Web Apps
📄 `infrastructure/arm-templates/main-cost-optimized-with-swa.json`
- Added Azure Static Web Apps resource
- Updated CORS settings for Functions
- Added outputs for Static Web App URL

### 2. GitHub Actions Workflow
📄 `.github/workflows/deploy-with-swa.yml`
- Builds and deploys frontend to Static Web Apps
- Handles both main branch and PR deployments
- Includes proper artifact management

### 3. PowerShell Deployment Script
📄 `infrastructure/scripts/deploy-with-swa.ps1`
- Automated deployment with parameter validation
- Retrieves Static Web Apps API token
- Provides next steps guidance

### 4. Static Web Apps Configuration
📄 `src/frontend/public/staticwebapp.config.json`
- Configures routing for React SPA
- Sets security headers
- Handles API routing

## Deployment Steps

### Step 1: Deploy Infrastructure
```powershell
cd infrastructure/scripts
./deploy-with-swa.ps1 -Environment dev -ResourceGroupName "rg-azpracticeexam-dev" -RepositoryUrl "https://github.com/YOUR-USERNAME/azure-practice-exam-platform"
```

### Step 2: Configure GitHub Secrets
The deployment script will output an API token. Add it to your GitHub repository:

1. Go to your GitHub repository
2. Settings → Secrets and variables → Actions
3. Add new repository secret:
   - **Name**: `AZURE_STATIC_WEB_APPS_API_TOKEN`
   - **Value**: [Token from deployment script output]

### Step 3: Update Repository URL
Update the ARM template parameter with your actual GitHub repository URL:
```json
"repositoryUrl": "https://github.com/YOUR-USERNAME/azure-practice-exam-platform"
```

### Step 4: Trigger Deployment
```bash
git add .
git commit -m "Add Static Web Apps configuration"
git push origin main
```

## Expected Results

After successful deployment, you'll have:

### 🌐 Live Frontend URL
```
https://azpracticeexam-dev-swa.azurestaticapps.net
```

### 🔗 Connected to Backend
- Frontend automatically connects to your live Functions API
- CORS configured for seamless communication
- Environment variables properly set

### 📊 Monitoring & Analytics
- Application Insights integration
- Performance monitoring
- Error tracking

## Troubleshooting

### Issue: Deployment Fails
**Solution**: Check GitHub Actions logs and ensure secrets are properly configured

### Issue: API Calls Failing
**Solution**: Verify CORS settings in Functions App and API base URL in frontend

### Issue: Static Web App Not Found
**Solution**: Ensure the repository URL parameter matches your actual GitHub repo

## Cost Analysis

| Resource | Pricing | Monthly Estimate |
|----------|---------|------------------|
| Azure Static Web Apps | Free tier | **$0** |
| Azure Functions | Consumption plan | **$0-5** |
| Application Insights | Free tier | **$0** |
| Storage Account | Cool tier | **$1-3** |
| Key Vault | Standard | **$1-2** |
| **Total** | | **$2-10 AUD/month** |

## Next Steps

1. **Custom Domain** (Optional): Configure your own domain
2. **SSL Certificate** (Automatic): Free Let's Encrypt certificates
3. **Environment Configuration**: Set up staging/production environments
4. **Performance Optimization**: Enable compression and caching

## Support
- [Azure Static Web Apps Documentation](https://docs.microsoft.com/en-us/azure/static-web-apps/)
- [GitHub Actions for Static Web Apps](https://docs.microsoft.com/en-us/azure/static-web-apps/github-actions-workflow)

---
**🎉 Your frontend is ready to go live!** Just follow the deployment steps above.