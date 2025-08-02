# Enhanced Bulk Question Upload Script for Azure Practice Exam Platform
# Supports multiple exam types and comprehensive error handling

param(
    [string]$ResourceGroup = "rg-azpracticeexam-dev",
    [string]$StorageAccount = "azpracticeexamdevstorage",
    [string]$ExamType = "AZ-104",
    [switch]$TestMode,
    [switch]$Verbose
)

# Enhanced question dataset
$AZ104Questions = @(
    @{
        Id = "az104-001"
        ExamType = "AZ-104"
        Category = "Identity and Governance"
        Difficulty = "Medium"
        Question = "Which Azure AD feature allows you to enforce multi-factor authentication based on conditions?"
        Options = @("Azure AD Premium P1", "Conditional Access", "Azure AD B2C", "Role-Based Access Control")
        CorrectAnswer = 1
        Explanation = "Conditional Access in Azure AD allows you to enforce MFA and other security policies based on specific conditions like location, device compliance, and sign-in risk."
    },
    @{
        Id = "az104-002"
        ExamType = "AZ-104"
        Category = "Storage"
        Difficulty = "Hard"
        Question = "What is the maximum size of a single blob in Azure Blob Storage?"
        Options = @("1 TB", "4.77 TB", "190.7 TB", "500 GB")
        CorrectAnswer = 2
        Explanation = "The maximum size for a single blob in Azure Blob Storage is approximately 190.7 TB."
    },
    @{
        Id = "az104-003"
        ExamType = "AZ-104"
        Category = "Virtual Machines"
        Difficulty = "Medium"
        Question = "Which Azure service provides Infrastructure as a Service (IaaS)?"
        Options = @("Azure Functions", "Azure Virtual Machines", "Azure App Service", "Azure Container Instances")
        CorrectAnswer = 1
        Explanation = "Azure Virtual Machines provide Infrastructure as a Service (IaaS), giving you complete control over the operating system and installed software."
    },
    @{
        Id = "az104-004"
        ExamType = "AZ-104"
        Category = "Networking"
        Difficulty = "Hard"
        Question = "What is the maximum number of virtual networks that can be peered with a single hub VNet?"
        Options = @("50 VNets", "100 VNets", "500 VNets", "No practical limit")
        CorrectAnswer = 2
        Explanation = "Azure supports up to 500 virtual network peerings per virtual network, making it possible to create large hub-and-spoke topologies."
    },
    @{
        Id = "az104-005"
        ExamType = "AZ-104"
        Category = "Storage"
        Difficulty = "Easy"
        Question = "Which three storage services are included in an Azure Storage Account?"
        Options = @("Blob, File, Queue", "Blob, Table, Database", "File, Queue, SQL", "Blob, File, Table")
        CorrectAnswer = 3
        Explanation = "An Azure Storage Account includes Blob storage, File storage, Queue storage, and Table storage services."
    },
    @{
        Id = "az104-006"
        ExamType = "AZ-104"
        Category = "Security"
        Difficulty = "Medium"
        Question = "Which Azure security feature provides just-in-time access to virtual machines?"
        Options = @("Azure Security Center", "Just-In-Time VM Access", "Network Security Groups", "Azure Firewall")
        CorrectAnswer = 1
        Explanation = "Just-In-Time (JIT) VM Access in Azure Security Center reduces exposure by providing time-limited access to VMs only when needed."
    },
    @{
        Id = "az104-007"
        ExamType = "AZ-104"
        Category = "Monitoring"
        Difficulty = "Medium"
        Question = "Which Azure service provides centralized logging and monitoring for Azure resources?"
        Options = @("Azure Monitor", "Azure Advisor", "Azure Service Health", "Azure Resource Health")
        CorrectAnswer = 0
        Explanation = "Azure Monitor is the comprehensive monitoring solution that collects, analyzes, and acts on telemetry from your cloud and on-premises environments."
    },
    @{
        Id = "az104-008"
        ExamType = "AZ-104"
        Category = "Virtual Machines"
        Difficulty = "Hard"
        Question = "What is the difference between Azure VM Scale Sets and Availability Sets?"
        Options = @("Scale Sets provide automatic scaling, Availability Sets provide fault domains", "Scale Sets provide fault domains, Availability Sets provide automatic scaling", "Both provide the same functionality", "Scale Sets are for Linux only")
        CorrectAnswer = 0
        Explanation = "VM Scale Sets provide automatic horizontal scaling based on demand. Availability Sets provide fault tolerance through fault domains and update domains but don't automatically scale."
    },
    @{
        Id = "az104-009"
        ExamType = "AZ-104"
        Category = "Networking"
        Difficulty = "Easy"
        Question = "Which Azure networking component acts as a firewall at the subnet level?"
        Options = @("Azure Firewall", "Network Security Group (NSG)", "Application Gateway", "Load Balancer")
        CorrectAnswer = 1
        Explanation = "Network Security Groups (NSGs) contain security rules that allow or deny network traffic based on source and destination IP address, port, and protocol."
    },
    @{
        Id = "az104-010"
        ExamType = "AZ-104"
        Category = "Identity and Governance"
        Difficulty = "Hard"
        Question = "In Azure RBAC, what is the correct hierarchy from most restrictive to least restrictive scope?"
        Options = @("Management Group > Subscription > Resource Group > Resource", "Resource > Resource Group > Subscription > Management Group", "Subscription > Management Group > Resource Group > Resource", "Resource Group > Resource > Subscription > Management Group")
        CorrectAnswer = 1
        Explanation = "Azure RBAC follows inheritance from parent to child scopes. The hierarchy from most restrictive to least restrictive is: Resource → Resource Group → Subscription → Management Group."
    }
)

$AZ900Questions = @(
    @{
        Id = "az900-001"
        ExamType = "AZ-900"
        Category = "Cloud Concepts"
        Difficulty = "Easy"
        Question = "Which cloud deployment model provides dedicated hardware that is not shared with other organizations?"
        Options = @("Public Cloud", "Private Cloud", "Hybrid Cloud", "Community Cloud")
        CorrectAnswer = 1
        Explanation = "Private Cloud provides dedicated infrastructure that is not shared with other organizations, offering the highest level of control and security."
    },
    @{
        Id = "az900-002"
        ExamType = "AZ-900"
        Category = "Azure Services"
        Difficulty = "Easy"
        Question = "Which Azure service category includes Virtual Machines, Virtual Networks, and Storage Accounts?"
        Options = @("Platform as a Service (PaaS)", "Software as a Service (SaaS)", "Infrastructure as a Service (IaaS)", "Function as a Service (FaaS)")
        CorrectAnswer = 2
        Explanation = "Infrastructure as a Service (IaaS) provides fundamental compute, network, and storage resources on demand."
    },
    @{
        Id = "az900-003"
        ExamType = "AZ-900"
        Category = "Security"
        Difficulty = "Medium"
        Question = "Which Azure service provides centralized security management and advanced threat protection?"
        Options = @("Azure Active Directory", "Azure Security Center", "Azure Key Vault", "Azure Sentinel")
        CorrectAnswer = 1
        Explanation = "Azure Security Center provides unified security management and advanced threat protection across hybrid cloud workloads."
    },
    @{
        Id = "az900-004"
        ExamType = "AZ-900"
        Category = "Pricing"
        Difficulty = "Medium"
        Question = "Which Azure cost management feature helps predict future costs based on current usage patterns?"
        Options = @("Azure Advisor", "Azure Cost Management", "Azure Pricing Calculator", "Azure TCO Calculator")
        CorrectAnswer = 1
        Explanation = "Azure Cost Management provides cost analysis, budgets, and forecasting capabilities to help predict future costs based on historical usage patterns."
    },
    @{
        Id = "az900-005"
        ExamType = "AZ-900"
        Category = "Compliance"
        Difficulty = "Easy"
        Question = "Which Azure feature ensures that resources comply with corporate standards and regulatory requirements?"
        Options = @("Azure Policy", "Azure Advisor", "Azure Monitor", "Azure Blueprints")
        CorrectAnswer = 0
        Explanation = "Azure Policy helps enforce organizational standards and assess compliance at scale by evaluating resources against business rules."
    }
)

# Function to upload questions with enhanced error handling
function Upload-Questions {
    param(
        [array]$Questions,
        [string]$StorageAccountName,
        [bool]$TestMode = $false
    )
    
    $successCount = 0
    $errorCount = 0
    $errors = @()
    
    Write-Host "📚 Uploading $($Questions.Count) questions..." -ForegroundColor Yellow
    
    foreach ($q in $Questions) {
        try {
            # Validate question structure
            if (-not $q.Id -or -not $q.ExamType -or -not $q.Question -or -not $q.Options -or $q.Options.Count -eq 0) {
                throw "Question $($q.Id) has missing required fields"
            }
            
            if ($q.CorrectAnswer -lt 0 -or $q.CorrectAnswer -ge $q.Options.Count) {
                throw "Question $($q.Id) has invalid correct answer index"
            }
            
            # Convert options to JSON
            $optionsJson = ($q.Options | ConvertTo-Json -Compress).Replace('"', '\"')
            
            if ($TestMode) {
                Write-Host "   [TEST MODE] Would upload: $($q.Id)" -ForegroundColor Cyan
                $successCount++
                continue
            }
            
            # Upload to Azure Tables
            $entityString = "PartitionKey=$($q.ExamType) RowKey=$($q.Id) Id=$($q.Id) ExamType=$($q.ExamType) Category=`"$($q.Category)`" Difficulty=$($q.Difficulty) Question=`"$($q.Question)`" OptionsJson=`"$optionsJson`" CorrectAnswer=$($q.CorrectAnswer) Explanation=`"$($q.Explanation)`""
            
            az storage entity insert --account-name $StorageAccountName --table-name "Questions" --entity $entityString --if-exists replace --output none
                
            if ($LASTEXITCODE -eq 0) {
                Write-Host "   ✅ $($q.Id): $($q.Question.Substring(0, [Math]::Min(50, $q.Question.Length)))..." -ForegroundColor Green
                $successCount++
            } else {
                throw "Azure CLI error occurred"
            }
            
        } catch {
            $errorMessage = $_.Exception.Message
            Write-Host "   ❌ $($q.Id): $errorMessage" -ForegroundColor Red
            $errors += "Question $($q.Id): $errorMessage"
            $errorCount++
        }
    }
    
    return @{
        SuccessCount = $successCount
        ErrorCount = $errorCount
        Errors = $errors
    }
}

# Main script execution
Write-Host "📝 Azure Practice Exam - Bulk Question Upload" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "Storage Account: $StorageAccount" -ForegroundColor White
Write-Host "Resource Group: $ResourceGroup" -ForegroundColor White
Write-Host "Exam Type: $ExamType" -ForegroundColor White
if ($TestMode) {
    Write-Host "Mode: TEST MODE (no actual uploads)" -ForegroundColor Yellow
}
Write-Host ""

# Check Azure CLI authentication
Write-Host "🔐 Checking Azure CLI authentication..." -ForegroundColor Yellow
try {
    $accountInfo = az account show --output json 2>$null | ConvertFrom-Json
    if ($accountInfo) {
        Write-Host "   ✅ Authenticated as: $($accountInfo.user.name)" -ForegroundColor Green
        Write-Host "   📋 Subscription: $($accountInfo.name)" -ForegroundColor White
    } else {
        throw "Not authenticated"
    }
} catch {
    Write-Host "   ❌ Not authenticated with Azure CLI" -ForegroundColor Red
    Write-Host "   💡 Run 'az login' first" -ForegroundColor Yellow
    exit 1
}

# Verify storage account exists
Write-Host "`n🗄️ Verifying storage account..." -ForegroundColor Yellow
try {
    az storage account show --name $StorageAccount --resource-group $ResourceGroup --output none 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✅ Storage account exists" -ForegroundColor Green
    } else {
        throw "Storage account not found"
    }
} catch {
    Write-Host "   ❌ Storage account '$StorageAccount' not found in resource group '$ResourceGroup'" -ForegroundColor Red
    exit 1
}

# Verify/Create Questions table
Write-Host "`n📊 Verifying Questions table..." -ForegroundColor Yellow
try {
    az storage table create --name "Questions" --account-name $StorageAccount --output none 2>$null
    Write-Host "   ✅ Questions table ready" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Failed to create/verify Questions table" -ForegroundColor Red
    exit 1
}

# Select questions based on exam type
$questionsToUpload = switch ($ExamType.ToUpper()) {
    "AZ-104" { $AZ104Questions }
    "AZ-900" { $AZ900Questions }
    default {
        Write-Host "❌ Unsupported exam type: $ExamType" -ForegroundColor Red
        Write-Host "💡 Supported types: AZ-104, AZ-900" -ForegroundColor Yellow
        exit 1
    }
}

# Upload questions
$result = Upload-Questions -Questions $questionsToUpload -StorageAccountName $StorageAccount -TestMode $TestMode

# Results summary
Write-Host "`n📊 Upload Summary" -ForegroundColor Cyan
Write-Host "=================" -ForegroundColor Cyan
Write-Host "Total Questions: $($questionsToUpload.Count)" -ForegroundColor White
Write-Host "Successful: $($result.SuccessCount)" -ForegroundColor Green
Write-Host "Failed: $($result.ErrorCount)" -ForegroundColor $(if ($result.ErrorCount -gt 0) { 'Red' } else { 'White' })

if ($result.ErrorCount -gt 0) {
    Write-Host "`n❌ Errors encountered:" -ForegroundColor Red
    foreach ($error in $result.Errors) {
        Write-Host "   • $error" -ForegroundColor Yellow
    }
}

# Success message
if ($result.SuccessCount -eq $questionsToUpload.Count) {
    Write-Host "`n🎉 All questions uploaded successfully!" -ForegroundColor Green
    
    if (-not $TestMode) {
        Write-Host "`n🧪 Test your API now:" -ForegroundColor Cyan
        Write-Host "   Invoke-RestMethod -Uri 'https://azpracticeexam-dev-functions.azurewebsites.net/api/questions/$ExamType' -Method GET" -ForegroundColor White
    }
} elseif ($result.SuccessCount -gt 0) {
    Write-Host "`n⚠️ Partial success. Some questions were uploaded." -ForegroundColor Yellow
} else {
    Write-Host "`n❌ No questions were uploaded successfully." -ForegroundColor Red
    exit 1
}

# Validation test
if (-not $TestMode -and $result.SuccessCount -gt 0) {
    Write-Host "`n🔍 Validating upload..." -ForegroundColor Yellow
    try {
        $apiResponse = Invoke-RestMethod -Uri "https://azpracticeexam-dev-functions.azurewebsites.net/api/questions/$ExamType" -Method GET -TimeoutSec 10
        Write-Host "   ✅ API returned $($apiResponse.Count) questions" -ForegroundColor Green
    } catch {
        Write-Host "   ⚠️ Could not validate via API: $($_.Exception.Message)" -ForegroundColor Yellow
        Write-Host "   💡 Questions may still be uploaded correctly" -ForegroundColor Gray
    }
}