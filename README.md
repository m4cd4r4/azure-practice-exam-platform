# Azure Practice Exam Platform

🎯 **Mission**: High-quality Azure certification practice exams with enterprise-grade cloud architecture.

## 🚀 LIVE DEPLOYMENT STATUS

**Frontend**: ✅ **READY TO DEPLOY** - Azure Static Web Apps configured
**Backend API**: ✅ **LIVE** at `https://azpracticeexam-dev-functions.azurewebsites.net`
**Database**: ✅ **OPERATIONAL** - Azure Tables with sample data

### 🌐 Expected Live URLs
- **Frontend**: `https://azpracticeexam-dev-swa.azurestaticapps.net` (after deployment)
- **Backend API**: `https://azpracticeexam-dev-functions.azurewebsites.net/api`

## 🏗️ Complete Architecture

### ✅ DEPLOYED & CONFIGURED
- **Backend**: Azure Functions (.NET 8) - Live API
- **Database**: Azure Tables - Operational with AZ-104 questions
- **Frontend**: React TypeScript app - Ready for Static Web Apps deployment
- **Infrastructure**: ARM templates with Static Web Apps
- **CI/CD**: GitHub Actions workflow for automatic deployment

## 📊 Current Status

### ✅ COMPLETED
- ✅ Azure infrastructure deployed (`rg-azpracticeexam-dev`)
- ✅ Azure Functions backend live and operational
- ✅ Azure Tables with question database
- ✅ React frontend app built and tested
- ✅ Static Web Apps ARM template created
- ✅ GitHub Actions CI/CD pipeline configured
- ✅ All deployment scripts ready

### 🚀 READY TO DEPLOY
- 🚀 Frontend deployment to Azure Static Web Apps
- 🚀 Complete end-to-end live platform

## 🚀 Deploy Frontend (3 Steps)

### Step 1: Deploy Infrastructure
```powershell
./quick-deploy-frontend.ps1
```

### Step 2: Add GitHub Secret
Copy API token from deployment output → GitHub Settings → Secrets → Actions
- Secret name: `AZURE_STATIC_WEB_APPS_API_TOKEN`

### Step 3: Trigger Deployment
```bash
git add .
git commit -m "Deploy frontend to Azure Static Web Apps"
git push origin main
```

## 🔧 Technology Stack

**LIVE PRODUCTION:**
- **Backend**: Azure Functions, C# .NET 8
- **Database**: Azure Tables
- **Frontend**: React, TypeScript, Tailwind CSS (ready to deploy)
- **Hosting**: Azure Static Web Apps (configured)
- **Infrastructure**: ARM Templates
- **CI/CD**: GitHub Actions
- **Monitoring**: Application Insights

## 📈 API Endpoints

### Live Endpoints:
- `GET /api/health` - Health check ✅
- `GET /api/questions/{examType}` - Get exam questions ✅
- `POST /api/exam/start` - Start exam session ✅
- `POST /api/exam/answer` - Submit answer ✅

## 💰 Cost Analysis

| Service | Tier | Monthly Cost |
|---------|------|--------------|
| Azure Static Web Apps | Free | $0 |
| Azure Functions | Consumption | $0-5 |
| Azure Tables | Pay-per-use | $1-3 |
| Application Insights | Free tier | $0 |
| **Total** | | **$1-8 AUD/month** |

## 🏆 Enterprise Features

✅ **Global CDN** - Azure Static Web Apps
✅ **Automatic SSL** - HTTPS certificates included
✅ **Serverless Backend** - Auto-scaling Azure Functions
✅ **Professional CI/CD** - GitHub Actions deployment
✅ **Cost-Optimized** - Free tier Static Web Apps
✅ **Production-Ready** - Enterprise security & monitoring

## 📁 Project Structure

```
azure-practice-exam-platform/
├── src/
│   ├── frontend/          # React TypeScript app
│   └── backend/           # Azure Functions (.NET 8)
├── infrastructure/        # ARM templates + deployment scripts
├── .github/workflows/     # CI/CD pipelines
└── docs/                  # Deployment guides
```

## 🎯 Current Achievement

**Professional Azure full-stack platform ready for deployment**
- Backend: Live and operational
- Frontend: Configured for Azure Static Web Apps
- Infrastructure: Cost-optimized ARM templates
- DevOps: Complete CI/CD pipeline

---

**Next Action**: Run `./quick-deploy-frontend.ps1` to go live!
**Last Updated**: August 2, 2025