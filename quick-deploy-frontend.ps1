# quick-deploy-frontend.ps1 - Quick deployment script for frontend

Write-Host "Azure Practice Exam Platform - Frontend Deployment" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Green

# Get repository URL
$repoUrl = git config --get remote.origin.url
Write-Host "Repository URL: $repoUrl" -ForegroundColor Yellow

# Ask for confirmation
$confirm = Read-Host "Deploy to Azure? (y/N)"
if ($confirm -ne "y" -and $confirm -ne "Y") {
    Write-Host "Deployment cancelled." -ForegroundColor Red
    exit 0
}

Write-Host "Starting deployment..." -ForegroundColor Blue

# Navigate to scripts directory
Set-Location infrastructure/scripts

# Run deployment script
try {
    ./deploy-with-swa.ps1 -Environment dev -ResourceGroupName "rg-azpracticeexam-dev" -RepositoryUrl $repoUrl
    
    Write-Host ""
    Write-Host "Deployment script completed!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "1. Copy the API token from above" -ForegroundColor White
    Write-Host "2. Add it to GitHub Secrets as AZURE_STATIC_WEB_APPS_API_TOKEN" -ForegroundColor White
    Write-Host "3. Push to main branch to trigger deployment" -ForegroundColor White
    Write-Host ""
    Write-Host "GitHub Secrets URL: $repoUrl/settings/secrets/actions" -ForegroundColor Cyan
}
catch {
    Write-Host "Deployment failed: $($_.Exception.Message)" -ForegroundColor Red
}