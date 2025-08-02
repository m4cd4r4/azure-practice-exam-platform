#!/bin/bash
# quick-deploy-frontend.sh - Quick deployment script for frontend

echo "🚀 Azure Practice Exam Platform - Frontend Deployment"
echo "=================================================="

# Get repository URL
REPO_URL=$(git config --get remote.origin.url)
echo "Repository URL: $REPO_URL"

# Ask for confirmation
read -p "Deploy to Azure? (y/N): " confirm
if [[ $confirm != [yY] ]]; then
    echo "Deployment cancelled."
    exit 0
fi

echo "Starting deployment..."

# Navigate to scripts directory
cd infrastructure/scripts

# Run PowerShell deployment script
pwsh -Command "
    ./deploy-with-swa.ps1 -Environment dev -ResourceGroupName 'rg-azpracticeexam-dev' -RepositoryUrl '$REPO_URL'
"

echo ""
echo "✅ Deployment script completed!"
echo ""
echo "Next steps:"
echo "1. Copy the API token from above"
echo "2. Add it to GitHub Secrets as AZURE_STATIC_WEB_APPS_API_TOKEN"
echo "3. Push to main branch to trigger deployment"
echo ""
echo "GitHub Secrets URL: $REPO_URL/settings/secrets/actions"