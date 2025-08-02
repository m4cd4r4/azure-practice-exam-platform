# deploy-with-swa.ps1 - Deploy infrastructure with Static Web Apps
param(
    [Parameter(Mandatory=$true)]
    [string]$Environment,
    
    [Parameter(Mandatory=$true)]
    [string]$ResourceGroupName,
    
    [Parameter(Mandatory=$false)]
    [string]$Location = "Australia East",
    
    [Parameter(Mandatory=$true)]
    [string]$RepositoryUrl,
    
    [Parameter(Mandatory=$false)]
    [string]$Branch = "main"
)

Write-Host "Deploying Azure Practice Exam Platform with Static Web Apps" -ForegroundColor Green
Write-Host "Environment: $Environment" -ForegroundColor Yellow
Write-Host "Resource Group: $ResourceGroupName" -ForegroundColor Yellow
Write-Host "Location: $Location" -ForegroundColor Yellow
Write-Host "Repository: $RepositoryUrl" -ForegroundColor Yellow

# Create resource group
Write-Host "Creating resource group..." -ForegroundColor Blue
az group create --name $ResourceGroupName --location $Location

# Deploy ARM template
Write-Host "Deploying ARM template..." -ForegroundColor Blue
$deploymentName = "deploy-$(Get-Date -Format 'yyyyMMdd-HHmmss')"

az deployment group create `
    --resource-group $ResourceGroupName `
    --template-file "../arm-templates/main-cost-optimized-with-swa.json" `
    --parameters environment=$Environment repositoryUrl=$RepositoryUrl branch=$Branch `
    --name $deploymentName

# Get outputs
Write-Host "Getting deployment outputs..." -ForegroundColor Blue
$outputs = az deployment group show --resource-group $ResourceGroupName --name $deploymentName --query properties.outputs

Write-Host "Deployment completed!" -ForegroundColor Green
Write-Host "Outputs:" -ForegroundColor Yellow
Write-Host $outputs

# Get Static Web Apps API token for GitHub Actions
Write-Host "Getting Static Web Apps API token..." -ForegroundColor Blue
$staticWebAppName = az deployment group show --resource-group $ResourceGroupName --name $deploymentName --query properties.outputs.staticWebAppName.value -o tsv

$apiToken = az staticwebapp secrets list --name $staticWebAppName --query properties.apiKey -o tsv

Write-Host "Static Web Apps API Token (add to GitHub Secrets as AZURE_STATIC_WEB_APPS_API_TOKEN):" -ForegroundColor Cyan
Write-Host $apiToken -ForegroundColor White

Write-Host ""
Write-Host "Next steps:" -ForegroundColor Green
Write-Host "1. Add the API token to your GitHub repository secrets" -ForegroundColor White
Write-Host "2. Update your ARM template file name in the workflow" -ForegroundColor White
Write-Host "3. Push to main branch to trigger deployment" -ForegroundColor White