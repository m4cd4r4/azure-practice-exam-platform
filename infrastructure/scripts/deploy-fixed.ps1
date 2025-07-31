param(
    [string]$Environment = "dev",
    [string]$ResourceGroupName = "rg-azpracticeexam-dev", 
    [string]$Location = "Australia East"
)

Write-Host "🚀 Deploying Azure Practice Exam Platform (Fixed Version)" -ForegroundColor Cyan
Write-Host "Environment: $Environment | Location: $Location" -ForegroundColor Yellow

# File paths - using fixed template
$templateFile = "..\arm-templates\main-cost-optimized-fixed.json"
$parametersFile = "..\arm-templates\parameters\$Environment-cost-optimized.parameters.json"

# Register provider
Write-Host "Registering providers..." -ForegroundColor Yellow
az provider register --namespace Microsoft.OperationalInsights

# Create resource group
Write-Host "Creating resource group..." -ForegroundColor Yellow
az group create --name $ResourceGroupName --location $Location

# Deploy
Write-Host "🚀 Deploying infrastructure..." -ForegroundColor Green
$deploymentName = "Deploy-Fixed-$(Get-Date -Format 'MMddHHmm')"

az deployment group create `
    --resource-group $ResourceGroupName `
    --template-file $templateFile `
    --parameters "@$parametersFile" `
    --name $deploymentName

if ($LASTEXITCODE -eq 0) {
    Write-Host "🎉 Deployment successful!" -ForegroundColor Green
    Write-Host "💰 Estimated cost: $0-10/month" -ForegroundColor Green
    
    # Show outputs
    az deployment group show --resource-group $ResourceGroupName --name $deploymentName --query properties.outputs
} else {
    Write-Host "❌ Deployment failed" -ForegroundColor Red
}
