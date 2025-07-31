# Azure Practice Exam Platform

🎯 **Mission**: Provide high-quality practice exams for Azure certifications while demonstrating enterprise-grade cloud architecture.

## 🏗️ Architecture Overview

This project demonstrates a cost-optimized, serverless-first architecture using Azure services:

- **Frontend**: React app hosted on Azure Static Web Apps (Free tier)
- **Backend**: Azure Functions (Consumption plan)
- **Database**: Azure Tables for questions, optional SQL for analytics
- **Monitoring**: Application Insights (Free tier)
- **Security**: Azure Key Vault, managed identities
- **Cost**: Optimized for `$0-15/month`

## 🚀 Quick Start

### Prerequisites
- Azure subscription
- Azure CLI or PowerShell
- Node.js 18+ (for frontend development)
- .NET 6+ (for backend development)

### Deployment
```powershell
# 1. Deploy infrastructure
cd infrastructure/scripts
.\deploy.ps1 -Environment dev -ResourceGroupName "rg-azpracticeexam-dev" -Location "Australia East"

# 2. Test deployment
.\test-deployment.ps1 -ResourceGroupName "rg-azpracticeexam-dev"
```

## 📊 Project Status

- ✅ Infrastructure design complete
- ✅ Cost-optimized ARM templates ready
- ⏳ Frontend development in progress
- ⏳ Backend API development in progress
- ⏳ Question database setup pending

## 💰 Cost Analysis

**Current monthly cost estimate**: $0-15 AUD
- Azure Functions: $0-5
- Storage Account: $0-2
- Application Insights: $0 (free tier)
- Static Web Apps: $0 (free tier)
- Key Vault: $0-1

See [cost analysis documentation](docs/cost-analysis/) for detailed breakdown.

## 🛠️ Technology Stack

- **Infrastructure**: Azure ARM Templates, Bicep
- **Frontend**: React, TypeScript, Tailwind CSS
- **Backend**: Azure Functions, C# .NET 6
- **Database**: Azure Tables, optional Azure SQL
- **Monitoring**: Application Insights, Azure Monitor
- **CI/CD**: GitHub Actions
- **Security**: Azure Key Vault, Azure AD B2C

## 📚 Documentation

- [Architecture Documentation](docs/architecture/)
- [Deployment Guide](docs/deployment/)
- [API Documentation](docs/api/)
- [Cost Analysis](docs/cost-analysis/)

## 🤝 Contributing

This is a portfolio project, but feedback and suggestions are welcome!

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Built with ❤️ for the Azure community and career advancement!**
