# ✅ Frontend Deployment Checklist

## Pre-Deployment Verification

### 🔍 Prerequisites Check
- [ ] Azure CLI installed and authenticated (`az login`)
- [ ] PowerShell 7+ or Windows PowerShell
- [ ] Git repository initialized with remote origin
- [ ] GitHub repository exists and is accessible

### 📋 Files Verification
- [ ] `infrastructure/arm-templates/main-cost-optimized-with-swa.json` exists
- [ ] `.github/workflows/deploy-with-swa.yml` exists  
- [ ] `src/frontend/public/staticwebapp.config.json` exists
- [ ] `quick-deploy-frontend.ps1` exists in root directory

## Deployment Process

### Step 1: Infrastructure Deployment
```powershell
# Navigate to project root
cd C:\Users\Hard-Worker\Documents\GitHub\Azure\azure-practice-exam-platform

# Run quick deployment
./quick-deploy-frontend.ps1
```

**Expected Output:**
- [ ] Resource group created successfully
- [ ] ARM template deployment succeeded
- [ ] Azure Static Web Apps API token displayed
- [ ] All Azure resources created without errors

### Step 2: GitHub Configuration
1. **Copy API Token** from deployment output
2. **Navigate to GitHub Secrets**:
   - Go to your repository on GitHub
   - Settings → Secrets and variables → Actions
   - Click "New repository secret"
3. **Add Secret**:
   - Name: `AZURE_STATIC_WEB_APPS_API_TOKEN`
   - Value: [Paste the API token]
   - Click "Add secret"

**Verification:**
- [ ] Secret `AZURE_STATIC_WEB_APPS_API_TOKEN` exists in GitHub
- [ ] Secret value matches deployment output

### Step 3: Trigger Deployment
```bash
# Add new files
git add .

# Commit changes
git commit -m "Add Azure Static Web Apps configuration for frontend deployment"

# Push to trigger CI/CD
git push origin main
```

**Expected Results:**
- [ ] GitHub Actions workflow triggers automatically
- [ ] Build job completes successfully
- [ ] Deploy job completes successfully
- [ ] Static Web App shows "Ready" status in Azure Portal

## Post-Deployment Verification

### 🌐 Live Application Check
- [ ] Frontend URL accessible: `https://azpracticeexam-dev-swa.azurestaticapps.net`
- [ ] Application loads without errors
- [ ] API calls to backend function successfully
- [ ] No console errors in browser developer tools

### 🔗 Integration Testing
- [ ] Frontend can fetch data from Azure Functions API
- [ ] CORS settings allow proper communication
- [ ] Environment variables loaded correctly
- [ ] Error handling works as expected

### 📊 Monitoring Verification
- [ ] Application Insights receiving frontend telemetry
- [ ] Azure Portal shows all resources as "Running"
- [ ] GitHub Actions history shows successful deployments
- [ ] No failed requests in Function App logs

## Troubleshooting Quick Fixes

### Issue: API Token Not Generated
**Solution:**
```powershell
# Manually get API token
az staticwebapp secrets list --name "azpracticeexam-dev-swa" --query properties.apiKey -o tsv
```

### Issue: GitHub Actions Failing
**Checks:**
- [ ] Secret `AZURE_STATIC_WEB_APPS_API_TOKEN` exists
- [ ] Repository URL in ARM template is correct
- [ ] Node.js version in workflow matches project requirements

### Issue: Frontend Not Loading
**Checks:**
- [ ] Build completed successfully in GitHub Actions
- [ ] Static Web App configuration is valid
- [ ] API base URL in environment variables is correct

### Issue: API Calls Failing
**Checks:**
- [ ] Azure Functions app is running
- [ ] CORS settings include Static Web App URL
- [ ] API endpoints are accessible independently

## Success Criteria

### ✅ Deployment Successful When:
- [ ] Frontend accessible at Azure Static Web Apps URL
- [ ] Backend API responding to requests
- [ ] GitHub Actions pipeline working
- [ ] Application Insights collecting data
- [ ] Total monthly cost remains under $10 AUD
- [ ] SSL certificate automatically provisioned

## Next Steps After Success

### 🚀 Optional Enhancements
- [ ] Configure custom domain name
- [ ] Set up staging environment
- [ ] Add more comprehensive monitoring
- [ ] Implement automated testing
- [ ] Configure backup strategies

### 📈 Portfolio Preparation
- [ ] Document the architecture in your resume
- [ ] Take screenshots of the live application
- [ ] Prepare demo script for interviews
- [ ] Document cost optimization strategies used

---

**🎉 Congratulations!** Once all items are checked, your Azure Practice Exam Platform will be fully live and production-ready!