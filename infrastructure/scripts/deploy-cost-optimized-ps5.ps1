#Requires -Modules Az

<#
.SYNOPSIS
    Deploy Azure Practice Exam Platform Infrastructure (Cost-Optimized) - PowerShell 5.1 Compatible
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
    .\deploy-cost-optimized-ps5.ps1 -Environment dev -ResourceGroupName "rg-azpracticeexam-dev" -Location "Australia East"
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
Write-Host "💰 Target Cost: `$0-15/month" -ForegroundColor Green
Write-Host "🎯 Environment: $Environment" -ForegroundColor Yellow
Write-Host "📍 Location: $Location" -ForegroundColor Yellow
Write-Host "📂 Resource Group: $ResourceGroupName" -ForegroundColor Yellow
Write-Host "PowerShell Version: $($PSVersionTable.PSVersion)" -ForegroundColor Cyan
Write-Host ""

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

# Check Azure connection
try {
    $context = Get-AzContext -ErrorAction Stop
    Write-Host "✅ Connected to Azure as: $($context.Account.Id)" -ForegroundColor Green
    Write-Host "   Subscription: $($context.Subscription.Name)" -ForegroundColor Cyan
} catch {
    Write-Host "❌ Not connected to Azure. Please run: Connect-AzAccount" -ForegroundColor Red
    exit 1
}

# Check if resource group exists, create if not
Write-Host "🔍 Checking resource group..." -ForegroundColor Yellow
$resourceGroup = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue
if (-not $resourceGroup) {
    Write-Host "🔄 Creating resource group '$ResourceGroupName'..." -ForegroundColor Yellow
    try {
        New-AzResourceGroup -Name $ResourceGroupName -Location $Location | Out-Null
        Write-Host "✅ Resource group created successfully" -ForegroundColor Green
    } catch {
        Write-Host "❌ Failed to create resource group: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "✅ Resource group exists" -ForegroundColor Green
}

# Validate template
Write-Host "🔍 Validating ARM template..." -ForegroundColor Yellow
try {
    $validationResult = Test-AzResourceGroupDeployment `
        -ResourceGroupName $ResourceGroupName `
        -TemplateFile $TemplateFile `
        -TemplateParameterFile $ParametersFile

    if ($validationResult) {
        Write-Host "❌ Template validation failed:" -ForegroundColor Red
        foreach ($error in $validationResult) {
            Write-Host "   $($error.Message)" -ForegroundColor Red
        }
        exit 1
    }
    Write-Host "✅ Template validation passed" -ForegroundColor Green
} catch {
    Write-Host "❌ Template validation error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

if ($WhatIf) {
    Write-Host "🔍 What-If mode - showing preview only..." -ForegroundColor Yellow
    Write-Host "   (Note: What-If requires PowerShell 7 for detailed preview)" -ForegroundColor Cyan
    Write-Host "✅ Validation completed. No resources deployed in What-If mode." -ForegroundColor Green
    exit 0
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
Write-Host ""
Write-Host "🚀 Starting deployment..." -ForegroundColor Green
Write-Host "   Deployment Name: $DeploymentName" -ForegroundColor Cyan
Write-Host ""

try {
    $deploymentResult = New-AzResourceGroupDeployment `
        -ResourceGroupName $ResourceGroupName `
        -TemplateFile $TemplateFile `
        -TemplateParameterFile $ParametersFile `
        -Name $DeploymentName `
        -Verbose

    if ($deploymentResult.ProvisioningState -eq "Succeeded") {
        Write-Host ""
        Write-Host "🎉 Deployment completed successfully!" -ForegroundColor Green
        Write-Host "================================================================" -ForegroundColor Green
        Write-Host ""
        Write-Host "📊 Deployment Details:" -ForegroundColor Cyan
        Write-Host "   Deployment Name: $($deploymentResult.DeploymentName)" -ForegroundColor White
        Write-Host "   Status: $($deploymentResult.ProvisioningState)" -ForegroundColor Green
        Write-Host "   Duration: $($deploymentResult.Timestamp)" -ForegroundColor White
        Write-Host ""
        
        Write-Host "📤 Resource URLs:" -ForegroundColor Cyan
        if ($deploymentResult.Outputs) {
            foreach ($output in $deploymentResult.Outputs.GetEnumerator()) {
                Write-Host "   $($output.Key): $($output.Value.Value)" -ForegroundColor White
            }
        }
        
        Write-Host ""
        Write-Host "💰 Estimated Cost: `$0-15 AUD/month" -ForegroundColor Green
        Write-Host ""
        Write-Host "🚀 Next Steps:" -ForegroundColor Yellow
        Write-Host "   1. Test deployment: cd .. && cd scripts && .\test-deployment.ps1 -ResourceGroupName '$ResourceGroupName'" -ForegroundColor White
        Write-Host "   2. Initialize Git: git init && git add . && git commit -m 'Initial deployment'" -ForegroundColor White
        Write-Host "   3. Connect GitHub to Static Web App" -ForegroundColor White
        Write-Host "   4. Start developing your application!" -ForegroundColor White
        Write-Host ""
        Write-Host "🎯 Congratulations! Your Azure Practice Exam Platform is deployed!" -ForegroundColor Green
        
    } else {
        Write-Host "❌ Deployment failed with status: $($deploymentResult.ProvisioningState)" -ForegroundColor Red
        if ($deploymentResult.Error) {
            Write-Host "Error Details: $($deploymentResult.Error)" -ForegroundColor Red
        }
        exit 1
    }
} catch {
    Write-Host "❌ Deployment failed with error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "🔍 Troubleshooting Tips:" -ForegroundColor Yellow
    Write-Host "   1. Check Azure permissions (need Contributor role)" -ForegroundColor White
    Write-Host "   2. Verify resource names are unique globally" -ForegroundColor White
    Write-Host "   3. Check Azure service availability in $Location" -ForegroundColor White
    Write-Host "   4. Review Azure Activity Log for detailed errors" -ForegroundColor White
    exit 1
}
