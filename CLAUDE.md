# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Architecture

This is an Azure Practice Exam Platform built with a full-stack architecture:

### Backend (.NET 8 Azure Functions)
- **Location**: `src/backend/ExamPlatform.Functions/`
- **Technology**: Azure Functions v4, .NET 8, C#
- **Database**: Azure Table Storage for questions and exam sessions
- **API Endpoints**: Anonymous access for questions, Function-level auth for admin operations
- **Key Files**:
  - `Functions/QuestionFunctions.cs`: Question CRUD operations with JSON error handling
  - `Functions/ExamSessionFunctions.cs`: Exam session management
  - `Functions/HealthFunctions.cs`: Health check endpoints
  - `Models/ExamModels.cs`: Data transfer objects

### Frontend (React TypeScript)
- **Location**: `src/frontend/`
- **Technology**: React 18, TypeScript, Tailwind CSS
- **Build Tool**: Create React App with react-scripts
- **Key Components**:
  - `src/App.tsx`: Main application shell
  - `src/components/Exam.tsx`: Exam taking interface
  - `src/components/ExamList.tsx`: Available exams display
  - `src/components/Question.tsx`: Individual question component
  - `src/services/api.ts`: Backend API integration

### Infrastructure (Azure ARM Templates)
- **Location**: `infrastructure/arm-templates/`
- **Deployment**: Cost-optimized templates for Azure Functions, Table Storage, Application Insights
- **Key Templates**:
  - `main-cost-optimized.json`: Primary infrastructure template
  - `main-cost-optimized-with-swa.json`: Includes Azure Static Web Apps

## Development Commands

### Backend Development
```bash
# Build and run Azure Functions locally
cd src/backend/ExamPlatform.Functions
dotnet restore
dotnet build
dotnet run # For local development with Azure Functions Core Tools
```

### Frontend Development
```bash
# Install dependencies and start development server
cd src/frontend
npm install --legacy-peer-deps
npm start # Starts on http://localhost:3000
npm run build # Production build
npm test # Run test suite
```

### Testing
```bash
# Frontend tests
cd src/frontend
npm test

# API testing (PowerShell)
cd scripts
.\test-api-comprehensive.ps1
```

### Deployment
```bash
# Deploy infrastructure
cd infrastructure/scripts
.\deploy-cost-optimized.ps1

# Deploy frontend to Azure Static Web Apps
.\quick-deploy-frontend.ps1

# GitHub Actions deployment (automatic on push to main)
# See .github/workflows/deploy.yml
```

## Key Development Notes

### Backend Considerations
- **JSON Handling**: QuestionFunctions includes robust JSON parsing for malformed data from Azure Tables
- **Error Handling**: All functions include comprehensive try-catch with logging
- **CORS**: Configured for frontend communication
- **Authentication**: Mixed levels - Anonymous for public endpoints, Function-level for admin

### Frontend Considerations
- **API Integration**: Uses environment-based configuration in `src/config/environment.ts`
- **State Management**: React hooks for local state, no external state library
- **Styling**: Tailwind CSS with responsive design
- **Error Handling**: Centralized in `src/services/errorHandler.ts`

### Data Model
Questions are stored in Azure Tables with this structure:
- PartitionKey: ExamType (e.g., "AZ-104", "AZ-900")
- RowKey: QuestionId
- Properties: Question text, OptionsJson (array), CorrectAnswer (int), Explanation, Category, Difficulty

### PowerShell Scripts
The `scripts/` directory contains management utilities:
- `fix-platform.ps1`: Quick setup and fixes
- `test-api-comprehensive.ps1`: Full API testing suite
- `upload-questions-bulk.ps1`: Bulk question upload
- See `scripts/README.md` for detailed usage

### GitHub Actions CI/CD
- **Trigger**: Push to main branch
- **Jobs**: Validate ARM template, deploy infrastructure, build frontend/backend, deploy Azure Functions
- **Secrets Required**: AZURE_CREDENTIALS, AZURE_SUBSCRIPTION_ID, AZURE_STATIC_WEB_APPS_API_TOKEN

## Architecture Patterns

### Error Resilience
- Backend functions gracefully handle malformed JSON data from storage
- Frontend includes retry logic and user-friendly error messages
- Comprehensive logging throughout the application stack

### Scalability
- Serverless Azure Functions auto-scale based on demand
- Azure Table Storage provides virtually unlimited scale
- Frontend deployed to Azure Static Web Apps with global CDN

### Cost Optimization
- Uses Azure Free Tiers where possible
- Consumption-based pricing for Functions
- Pay-per-use Table Storage
- Estimated monthly cost: $1-8 AUD

## Development Workflow

1. **Local Development**: Run backend Functions locally, frontend on localhost:3000
2. **Testing**: Use PowerShell scripts for API testing, npm test for frontend
3. **Deployment**: GitHub Actions handles automatic deployment on main branch push
4. **Monitoring**: Application Insights provides telemetry and error tracking