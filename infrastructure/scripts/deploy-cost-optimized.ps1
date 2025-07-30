#Requires -Version 7.0
#Requires -Modules Az

<#
.SYNOPSIS
    Deploy Azure Practice Exam Platform Infrastructure (Cost-Optimized)
.DESCRIPTION
    This script deploys the cost-optimized infrastructure for the Azure Practice Exam Platform
.PARAMETER Environment
    The environment to deploy to (dev, staging, prod)
.PARAMETER ResourceGroupName
    The name of the resource group to deploy to
.PARAMETER Location
    The Azure region to deploy to
.PARAMETER WhatIf
    Run in what-if mode to preview changes without deploying
.EXAMPLE
    .\deploy-cost-optimized.ps1 -Environment dev -ResourceGroupName "rg-azpracticeexam-dev" -Location "Australia East"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("dev", "staging", "prod")]
    [string]$Environment,
    
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,
    
    [Parameter(Mandatory = $true)]
    [string]$Location,
    
    [Parameter(Mandatory = $false)]
    [switch]$WhatIf
)

# Script variables
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$TemplateFile = Join-Path (Split-Path -Parent $ScriptPath) "arm-templates\main-cost-optimized.json"
$ParametersFile = Join-Path (Split-Path -Parent $ScriptPath) "arm-templates\parameters\$Environment-cost-optimized.parameters.json"
$DeploymentName = "CostOptimized-$Environment-$(Get-Date -Format 'yyyyMMdd-HHmmss')"

Write-Host "🚀 Azure Practice Exam Platform - Cost-Optimized Deployment" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "💰 Target Cost: $0-15/month" -ForegroundColor Green
Write-Host "🎯 Environment: $Environment" -ForegroundColor Yellow
Write-Host "📍 Location: $Location" -ForegroundColor Yellow
Write-Host "📂 Resource Group: $ResourceGroupName" -ForegroundColor Yellow
Write-Host ""

# Check if resource group exists, create if not
$resourceGroup = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue
if (-not $resourceGroup) {
    Write-Host "🔄 Creating resource group '$ResourceGroupName'..." -ForegroundColor Yellow
    New-AzResourceGroup -Name $ResourceGroupName -Location $Location | Out-Null
    Write-Host "✅ Resource group created" -ForegroundColor Green
} else {
    Write-Host "✅ Resource group exists" -ForegroundColor Green
}

# Validate template
Write-Host "🔍 Validating ARM template..." -ForegroundColor Yellow
$validationResult = Test-AzResourceGroupDeployment `
    -ResourceGroupName $ResourceGroupName `
    -TemplateFile $TemplateFile `
    -TemplateParameterFile $ParametersFile

if ($validationResult) {
    Write-Host "❌ Template validation failed:" -ForegroundColor Red
    $validationResult | ForEach-Object { Write-Host "   $($_.Message)" -ForegroundColor Red }
    exit 1
}
Write-Host "✅ Template validation passed" -ForegroundColor Green

if ($WhatIf) {
    Write-Host "🔍 Running What-If analysis..." -ForegroundColor Yellow
    $whatIfResult = Get-AzResourceGroupDeploymentWhatIfResult `
        -ResourceGroupName $ResourceGroupName `
        -TemplateFile $TemplateFile `
        -TemplateParameterFile $ParametersFile
    
    Write-Host $whatIfResult
    Write-Host "✅ What-If completed. No resources deployed." -ForegroundColor Green
    exit 0
}

# Deploy
Write-Host "🚀 Starting deployment..." -ForegroundColor Green
$deploymentResult = New-AzResourceGroupDeployment `
    -ResourceGroupName $ResourceGroupName `
    -TemplateFile $TemplateFile `
    -TemplateParameterFile $ParametersFile `
    -Name $DeploymentName `
    -Verbose

if ($deploymentResult.ProvisioningState -eq "Succeeded") {
    Write-Host ""
    Write-Host "🎉 Deployment completed successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📊 Deployment Outputs:" -ForegroundColor Cyan
    
    foreach ($output in $deploymentResult.Outputs.GetEnumerator()) {
        Write-Host "   $($output.Key): $($output.Value.Value)" -ForegroundColor White
    }
    
    Write-Host ""
    Write-Host "💰 Cost Estimate: $0-15 AUD/month" -ForegroundColor Green
    Write-Host ""
    Write-Host "🚀 Next Steps:" -ForegroundColor Yellow
    Write-Host "   1. Run test script: .\test-deployment.ps1 -ResourceGroupName '$ResourceGroupName'" -ForegroundColor White
    Write-Host "   2. Connect GitHub repository to Static Web App" -ForegroundColor White
    Write-Host "   3. Deploy Function App code" -ForegroundColor White
    Write-Host "   4. Add sample questions to Azure Tables" -ForegroundColor White
    
} else {
    Write-Host "❌ Deployment failed: $($deploymentResult.ProvisioningState)" -ForegroundColor Red
    exit 1
}
