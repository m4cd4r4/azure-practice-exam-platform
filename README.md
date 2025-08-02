# Azure Practice Exam Platform

🎯 **Mission**: Provide high-quality practice exams for Azure certifications while demonstrating enterprise-grade cloud architecture.

## 🚀 LIVE DEPLOYMENT STATUS

**Backend API**: ✅ **LIVE** at `https://azpracticeexam-dev-functions.azurewebsites.net`
**Frontend**: ❌ **Configuration Issues** (localhost:3000 not loading)
**Database**: ✅ **OPERATIONAL** (Azure Tables with sample data)

### 🌐 Live Endpoints
- **Health Check**: https://azpracticeexam-dev-functions.azurewebsites.net/api/health ✅
- **Questions API**: https://azpracticeexam-dev-functions.azurewebsites.net/api/questions/AZ-104 ⚠️ (500 error - connection string issue)

## 🏗️ Architecture Overview

**DEPLOYED SERVICES:**
- **Backend**: Azure Functions (.NET 8) - **LIVE** ✅
- **Database**: Azure Tables - **OPERATIONAL** ✅  
- **Storage**: Azure Storage Account - **CONFIGURED** ✅
- **Frontend**: React TypeScript app - **NEEDS FIXING** ❌

## 📊 Current Project Status

### ✅ COMPLETED
- ✅ Azure infrastructure deployed (`rg-azpracticeexam-dev`)
- ✅ C# .NET 8 Function App deployed to Azure
- ✅ Azure Tables configured with question data
- ✅ API endpoints created (health, questions, exam sessions)
- ✅ Anonymous authentication configured
- ✅ Sample AZ-104 questions uploaded
- ✅ React frontend components developed

### ⚠️ KNOWN ISSUES
- ❌ Function App connection string configuration (causing 500 errors)
- ❌ Frontend not loading at localhost:3000
- ❌ Bulk question upload scripts need debugging
- ❌ End-to-end testing incomplete

### ⏳ PENDING
- ⏳ Complete question database population (47 questions)
- ⏳ Frontend deployment to Azure Static Web Apps
- ⏳ Connection string troubleshooting
- ⏳ End-to-end integration testing

## 🚀 Quick Start

### Test Live Backend APIs

**PowerShell:**
```powershell
# Health check (working)
Invoke-RestMethod -Uri "https://azpracticeexam-dev-functions.azurewebsites.net/api/health" -Method GET

# Questions API (returns 500 - needs connection string fix)
Invoke-RestMethod -Uri "https://azpracticeexam-dev-functions.azurewebsites.net/api/questions/AZ-104" -Method GET
```

**Curl:**
```bash
# Health check
curl -X GET "https://azpracticeexam-dev-functions.azurewebsites.net/api/health"

# Questions API
curl -X GET "https://azpracticeexam-dev-functions.azurewebsites.net/api/questions/AZ-104"
```

### Run Frontend Locally (NEEDS FIXING)

```bash
cd src/frontend
npm install
npm start
# Should open at http://localhost:3000 (currently failing)
```

### Add More Questions

```powershell
az storage entity insert --account-name azpracticeexamdevstorage --table-name Questions --entity "PartitionKey=AZ-104" "RowKey=az104-003" "Id=az104-003" "ExamType=AZ-104" "Category=Networking" "Difficulty=Medium" "Question=Which Azure service provides DDoS protection?" "OptionsJson=[`"Azure Firewall`",`"Azure DDoS Protection`",`"Network Security Groups`",`"Application Gateway`"]" "CorrectAnswer=1" "Explanation=Azure DDoS Protection provides comprehensive DDoS mitigation." --auth-mode key --if-exists replace
```

## 🔧 Deployed Infrastructure

**Resource Group**: `rg-azpracticeexam-dev`
**Region**: Australia East

### Live Resources:
- **Function App**: `azpracticeexam-dev-functions`
- **Storage Account**: `azpracticeexamdevstorage`  
- **Tables**: `Questions`, `ExamSessions`

## 🛠️ Technology Stack

**DEPLOYED:**
- **Backend**: Azure Functions, C# .NET 8 ✅
- **Database**: Azure Tables ✅
- **Infrastructure**: ARM Templates ✅
- **Authentication**: Anonymous (public access) ✅

**IN DEVELOPMENT:**
- **Frontend**: React, TypeScript, Tailwind CSS ❌
- **CI/CD**: GitHub Actions ⏳
- **Monitoring**: Application Insights ⏳

## 🐛 Troubleshooting

### Fix Connection String Issue:
1. Go to Azure Portal → Function Apps → `azpracticeexam-dev-functions`
2. Settings → Configuration
3. Add/Update: `AzureWebJobsStorage` with storage connection string

### Fix Frontend Loading:
```bash
cd src/frontend
npm install --force
npm audit fix
npm start
```

## 📈 API Documentation

### Working Endpoints:
- `GET /api/health` - Health check ✅
- `GET /api/ping` - Simple ping ✅

### Endpoints with Issues:
- `GET /api/questions/{examType}` - Get questions ⚠️ (500 error)
- `POST /api/exam/start` - Start exam session ⚠️ (500 error)
- `POST /api/exam/answer` - Submit answer ⚠️ (500 error)

## 💰 Current Cost: ~$0/month

All services running on free/consumption tiers.

## 🏆 Achievement Unlocked

✅ **Successfully deployed C# .NET Function App to Azure**
✅ **Configured Azure Tables with question data**  
✅ **Created working API endpoints**
✅ **Demonstrated serverless cloud architecture**

---

**Status**: Backend deployed and partially functional. Frontend and full integration pending.
**Last Updated**: August 2, 2025
