param(
    [string]$Environment = "dev",
    [string]$ResourceGroupName = "rg-azpracticeexam-dev", 
    [string]$Location = "Australia East"
)

Write-Host "🚀 Deploying Azure Practice Exam Platform" -ForegroundColor Cyan
Write-Host "Environment: $Environment | Location: $Location" -ForegroundColor Yellow

# Check Azure CLI
try {
    az account show | Out-Null
    Write-Host "✅ Azure CLI ready" -ForegroundColor Green
} catch {
    Write-Host "❌ Please run: az login" -ForegroundColor Red
    exit 1
}

# File paths
$templateFile = "..\arm-templates\main-cost-optimized.json"
$parametersFile = "..\arm-templates\parameters\$Environment-cost-optimized.parameters.json"

# Create resource group
Write-Host "Creating resource group..." -ForegroundColor Yellow
az group create --name $ResourceGroupName --location $Location

# Deploy
Write-Host "🚀 Deploying infrastructure..." -ForegroundColor Green
$deploymentName = "Deploy-$(Get-Date -Format 'MMddHHmm')"

az deployment group create `
    --resource-group $ResourceGroupName `
    --template-file $templateFile `
    --parameters "@$parametersFile" `
    --name $deploymentName

if ($LASTEXITCODE -eq 0) {
    Write-Host "🎉 Deployment successful!" -ForegroundColor Green
    Write-Host "💰 Estimated cost: $0-15/month" -ForegroundColor Green
} else {
    Write-Host "❌ Deployment failed" -ForegroundColor Red
}
