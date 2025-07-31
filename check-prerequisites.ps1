# Quick Prerequisites Check
Write-Host "🔍 Checking Prerequisites..." -ForegroundColor Cyan

# Check PowerShell version
$psVersion = $PSVersionTable.PSVersion
Write-Host "PowerShell Version: $psVersion" -ForegroundColor $(if($psVersion.Major -ge 5) {"Green"} else {"Red"})

# Check if Az module is installed
$azModule = Get-Module -Name Az -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1
if ($azModule) {
    Write-Host "✅ Azure PowerShell Module: $($azModule.Version)" -ForegroundColor Green
} else {
    Write-Host "❌ Azure PowerShell Module not found" -ForegroundColor Red
    Write-Host "Installing Azure PowerShell Module..." -ForegroundColor Yellow
    Install-Module -Name Az -AllowClobber -Scope CurrentUser -Force
}

# Check Azure connection
try {
    $context = Get-AzContext -ErrorAction SilentlyContinue
    if ($context) {
        Write-Host "✅ Connected to Azure as: $($context.Account.Id)" -ForegroundColor Green
        Write-Host "   Subscription: $($context.Subscription.Name)" -ForegroundColor Cyan
    } else {
        Write-Host "❌ Not connected to Azure" -ForegroundColor Red
        Write-Host "Run: Connect-AzAccount" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Azure connection check failed" -ForegroundColor Red
    Write-Host "Run: Connect-AzAccount" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "🚀 If all checks pass, you're ready to deploy!" -ForegroundColor Green
