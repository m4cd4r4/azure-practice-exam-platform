# Azure Practice Exam Platform - Deploy using Azure CLI
# This version uses Azure CLI instead of PowerShell Az module

param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("dev", "staging", "prod")]
    [string]$Environment,
    
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,
    
    [Parameter(Mandatory = $true)]
    [string]$Location
)

Write-Host "🚀 Azure Practice Exam Platform - CLI Deployment" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "💰 Target Cost: `$0-15/month" -ForegroundColor Green
Write-Host "🎯 Environment: $Environment" -ForegroundColor Yellow
Write-Host "📍 Location: $Location" -ForegroundColor Yellow
Write-Host "📂 Resource Group: $ResourceGroupName" -ForegroundColor Yellow
Write-Host ""

# Check if Azure CLI is installed
try {
    $azVersion = az --version 2>$null
    if ($azVersion) {
        Write-Host "✅ Azure CLI is installed" -ForegroundColor Green
    } else {
        throw "Azure CLI not found"
    }
} catch {
    Write-Host "❌ Azure CLI not found" -ForegroundColor Red
    exit 1
}

# Check if logged in to Azure
Write-Host "🔍 Checking Azure login..." -ForegroundColor Yellow
$accountJson = az account show 2>$null
if (-not $accountJson) {
    Write-Host "❌ Not logged in to Azure. Logging in..." -ForegroundColor Red
    az login
    $accountJson = az account show
}

$account = $accountJson | ConvertFrom-Json
Write-Host "✅ Logged in as: $($account.user.name)" -ForegroundColor Green
Write-Host "   Subscription: $($account.name)" -ForegroundColor Cyan
Write-Host ""

# Set up file paths
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$TemplateFile = Join-Path (Split-Path -Parent $ScriptPath) "arm-templates\main-cost-optimized.json"
$ParametersFile = Join-Path (Split-Path -Parent $ScriptPath) "arm-templates\parameters\$Environment-cost-optimized.parameters.json"

# Check if files exist
if (-not (Test-Path $TemplateFile)) {
    Write-Host "❌ Template file not found: $TemplateFile" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $ParametersFile)) {
    Write-Host "❌ Parameters file not found: $ParametersFile" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Template files found" -ForegroundColor Green

# Create resource group
Write-Host "🔄 Creating resource group '$ResourceGroupName'..." -ForegroundColor Yellow
az group create --name $ResourceGroupName --location $Location --output none
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Resource group ready" -ForegroundColor Green
} else {
    Write-Host "❌ Failed to create resource group" -ForegroundColor Red
    exit 1
}

# Validate template
Write-Host "🔍 Validating ARM template..." -ForegroundColor Yellow
$validation = az deployment group validate --resource-group $ResourceGroupName --template-file $TemplateFile --parameters "@$ParametersFile" --output json 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Template validation passed" -ForegroundColor Green
} else {
    Write-Host "❌ Template validation failed:" -ForegroundColor Red
    Write-Host $validation -ForegroundColor Red
    exit 1
}

# Confirm deployment
Write-Host ""
Write-Host "⚠️  Ready to deploy infrastructure to Azure" -ForegroundColor Yellow
Write-Host "   This will create resources that may incur costs (estimated `$0-15/month)" -ForegroundColor Yellow
$confirmation = Read-Host "Continue with deployment? (y/N)"
if ($confirmation -notmatch '^[Yy]$') {
    Write-Host "❌ Deployment cancelled by user" -ForegroundColor Yellow
    exit 0
}

# Deploy
$DeploymentName = "CLIDeploy-$Environment-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
Write-Host ""
Write-Host "🚀 Starting deployment..." -ForegroundColor Green
Write-Host "   Deployment Name: $DeploymentName" -ForegroundColor Cyan
Write-Host ""

$deploymentJson = az deployment group create --resource-group $ResourceGroupName --template-file $TemplateFile --parameters "@$ParametersFile" --name $DeploymentName --output json

if ($LASTEXITCODE -eq 0) {
    $deploymentResult = $deploymentJson | ConvertFrom-Json
    
    Write-Host ""
    Write-Host "🎉 Deployment completed successfully!" -ForegroundColor Green
    Write-Host "======================================" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "📊 Deployment Details:" -ForegroundColor Cyan
    Write-Host "   Name: $($deploymentResult.name)" -ForegroundColor White
    Write-Host "   Status: $($deploymentResult.properties.provisioningState)" -ForegroundColor Green
    Write-Host "   Resource Group: $ResourceGroupName" -ForegroundColor White
    Write-Host ""
    
    if ($deploymentResult.properties.outputs) {
        Write-Host "📤 Deployment Outputs:" -ForegroundColor Cyan
        $deploymentResult.properties.outputs.PSObject.Properties | ForEach-Object {
            Write-Host "   $($_.Name): $($_.Value.value)" -ForegroundColor White
        }
        Write-Host ""
    }
    
    Write-Host "💰 Estimated Monthly Cost: `$0-15 AUD" -ForegroundColor Green
    Write-Host ""
    Write-Host "🚀 Next Steps:" -ForegroundColor Yellow
    Write-Host "   1. Your infrastructure is now deployed!" -ForegroundColor White
    Write-Host "   2. Check Azure Portal to see your resources" -ForegroundColor White
    Write-Host "   3. Connect your GitHub repository to the Static Web App" -ForegroundColor White
    Write-Host "   4. Start developing your application" -ForegroundColor White
    Write-Host ""
    Write-Host "🌐 View in Azure Portal:" -ForegroundColor Cyan
    Write-Host "   https://portal.azure.com/#@/resource/subscriptions/$($account.id)/resourceGroups/$ResourceGroupName" -ForegroundColor Blue
    Write-Host ""
    Write-Host "🎯 Congratulations! Your Azure Practice Exam Platform is live!" -ForegroundColor Green
    
} else {
    Write-Host "❌ Deployment failed!" -ForegroundColor Red
    Write-Host $deploymentJson -ForegroundColor Red
    exit 1
}
