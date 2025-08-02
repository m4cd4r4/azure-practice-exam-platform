# 🛠️ Azure Practice Exam Platform - Scripts Directory

This directory contains utility scripts for managing and testing your Azure Practice Exam Platform.

## 📁 Script Overview

### Core Management Scripts

| Script | Purpose | Usage |
|--------|---------|-------|
| `fix-platform.ps1` | Quick fix for common issues | `.\fix-platform.ps1` |
| `test-api-comprehensive.ps1` | Full API testing suite | `.\test-api-comprehensive.ps1` |
| `upload-questions-bulk.ps1` | Bulk question upload | `.\upload-questions-bulk.ps1 -ExamType AZ-104` |

### Quick Start Scripts

```powershell
# Fix common issues and get platform running
.\fix-platform.ps1

# Test all API endpoints
.\test-api-comprehensive.ps1 -Verbose

# Upload sample questions
.\upload-questions-bulk.ps1 -ExamType AZ-104
.\upload-questions-bulk.ps1 -ExamType AZ-900
```

## 🚀 Quick Fix Script

**File**: `fix-platform.ps1`

Automatically fixes the most common issues with your platform:

- ✅ Updates Azure Function App connection strings
- ✅ Fixes frontend npm dependencies  
- ✅ Tests API connectivity
- ✅ Adds sample questions
- ✅ Starts the React development server

```powershell
# Run the complete fix
.\fix-platform.ps1

# The script will:
# 1. Update backend connection string
# 2. Fix frontend dependencies
# 3. Add sample questions
# 4. Start localhost:3000
```

## 🧪 API Testing Script

**File**: `test-api-comprehensive.ps1`

Comprehensive testing of all API endpoints with performance analysis:

```powershell
# Basic test
.\test-api-comprehensive.ps1

# Detailed test with verbose output
.\test-api-comprehensive.ps1 -Verbose

# Test specific exam type
.\test-api-comprehensive.ps1 -ExamType AZ-900

# Test different environment
.\test-api-comprehensive.ps1 -BaseUrl "https://azpracticeexam-prod-functions.azurewebsites.net/api"
```

**Features:**
- ✅ Tests all API endpoints (health, questions, exam sessions)
- ✅ Performance analysis with response times
- ✅ Connectivity diagnostics
- ✅ Data analysis (question counts, categories)
- ✅ Detailed error reporting
- ✅ Success rate calculation

## 📚 Question Upload Script

**File**: `upload-questions-bulk.ps1`

Bulk upload questions with validation and error handling:

```powershell
# Upload AZ-104 questions
.\upload-questions-bulk.ps1 -ExamType AZ-104

# Upload AZ-900 questions  
.\upload-questions-bulk.ps1 -ExamType AZ-900

# Test mode (no actual uploads)
.\upload-questions-bulk.ps1 -ExamType AZ-104 -TestMode

# Verbose output
.\upload-questions-bulk.ps1 -ExamType AZ-104 -Verbose
```

**Features:**
- ✅ Pre-built question sets for AZ-104 and AZ-900
- ✅ Question validation before upload
- ✅ Error handling and retry logic
- ✅ Test mode for validation
- ✅ Progress tracking and detailed reporting

## 🔧 Prerequisites

Before running these scripts, ensure you have:

1. **Azure CLI installed and authenticated**:
   ```powershell
   az login
   az account set --subscription "Your Subscription"
   ```

2. **PowerShell execution policy set**:
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

3. **Node.js and npm installed** (for frontend scripts)

4. **Access to the Azure resource group**:
   - Resource Group: `rg-azpracticeexam-dev`
   - Storage Account: `azpracticeexamdevstorage`
   - Function App: `azpracticeexam-dev-functions`

## 🎯 Common Scenarios

### Scenario 1: Fresh Setup
```powershell
# Complete platform setup from scratch
.\fix-platform.ps1
.\upload-questions-bulk.ps1 -ExamType AZ-104
.\upload-questions-bulk.ps1 -ExamType AZ-900
.\test-api-comprehensive.ps1
```

### Scenario 2: API Issues
```powershell
# Debug API problems
.\test-api-comprehensive.ps1 -Verbose
# Review the error messages and fix connection strings if needed
```

### Scenario 3: Add More Questions
```powershell
# Add questions for specific exam type
.\upload-questions-bulk.ps1 -ExamType AZ-104
```

### Scenario 4: Frontend Not Loading
```powershell
# Focus on frontend fixes
cd ../src/frontend
npm install --legacy-peer-deps
npm start
```

## 📊 Expected Outputs

### Successful Fix Script Output:
```
🚀 Azure Practice Exam Platform - Quick Fix Script
=================================================
✅ Backend connection string updated
✅ Frontend dependencies fixed
✅ Sample questions added
🌐 Check http://localhost:3000 for your app!
```

### Successful API Test Output:
```
🧪 Azure Practice Exam Platform - API Test Suite
=================================================
✅ Health Check (245ms)
✅ Ping Endpoint (156ms)
✅ Get All Questions (432ms)
✅ Get Random Questions (389ms)
✅ Start Exam Session (678ms)

Success Rate: 100%
```

### Successful Question Upload Output:
```
📝 Azure Practice Exam - Bulk Question Upload
=============================================
✅ az104-001: Which Azure AD feature allows you to enforce...
✅ az104-002: What is the maximum size of a single blob...
✅ az104-003: Which Azure service provides Infrastructure...

Upload Summary: 10/10 successful
```

## 🐛 Troubleshooting

### Common Issues and Solutions:

**Issue**: "Not authenticated with Azure CLI"
```powershell
az login
az account list --output table
az account set --subscription "Your Subscription Name"
```

**Issue**: "Storage account not found"
- Verify resource group and storage account names
- Check that resources are deployed
- Ensure you have proper permissions

**Issue**: "Frontend not starting"
```powershell
cd ../src/frontend
rm -rf node_modules
rm package-lock.json
npm install --legacy-peer-deps
npm start
```

**Issue**: "API returning 500 errors"
- Run the fix script to update connection strings
- Check Function App status in Azure Portal
- Review Function App logs for detailed errors

## 🔄 Maintenance Scripts

### Weekly Maintenance:
```powershell
# Test platform health
.\test-api-comprehensive.ps1

# Add new questions if available
.\upload-questions-bulk.ps1 -ExamType AZ-104
```

### Deployment Updates:
```powershell
# After deploying backend changes
.\fix-platform.ps1
.\test-api-comprehensive.ps1
```

## 📈 Monitoring and Analytics

The scripts provide built-in monitoring capabilities:

- **Performance Metrics**: Response times for all endpoints
- **Success Rates**: Percentage of successful API calls
- **Data Analytics**: Question counts, categories, difficulty distribution
- **Error Tracking**: Detailed error messages and suggestions

## 🎓 Next Steps

After running these scripts successfully:

1. **Test the complete user flow** at http://localhost:3000
2. **Add more questions** using the bulk upload script
3. **Deploy frontend** to Azure Static Web Apps
4. **Set up monitoring** with Application Insights
5. **Configure CI/CD** with GitHub Actions

## 💡 Pro Tips

- Run scripts from the `scripts` directory for proper relative paths
- Use `-TestMode` flag when experimenting with question uploads
- Check Azure Portal if scripts report authentication issues
- Use `-Verbose` flag for detailed debugging information
- Scripts are designed to be idempotent (safe to run multiple times)

---

**Need Help?** Check the main README.md or review the individual script comments for detailed documentation.