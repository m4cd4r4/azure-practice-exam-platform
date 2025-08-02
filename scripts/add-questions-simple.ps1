# Simple Question Upload Script for Azure Practice Exam Platform
param(
    [string]$ExamType = "AZ-104"
)

$StorageAccount = "azpracticeexamdevstorage"

Write-Host "Adding questions for $ExamType..." -ForegroundColor Yellow

# Simple question data
$questions = @(
    @{
        Id = "az104-001"
        Question = "Which Azure service provides Infrastructure as a Service?"
        Options = '["Azure Functions","Azure Virtual Machines","Azure App Service","Azure Logic Apps"]'
        CorrectAnswer = 1
        Category = "Virtual Machines"
        Difficulty = "Easy"
        Explanation = "Azure Virtual Machines provide IaaS with full control over the operating system."
    },
    @{
        Id = "az104-002"
        Question = "What is the maximum size of a single blob in Azure Blob Storage?"
        Options = '["1 TB","4.77 TB","190.7 TB","500 GB"]'
        CorrectAnswer = 2
        Category = "Storage"
        Difficulty = "Medium"
        Explanation = "The maximum size for a single blob in Azure Blob Storage is approximately 190.7 TB."
    },
    @{
        Id = "az104-003"
        Question = "Which Azure AD feature allows you to enforce multi-factor authentication?"
        Options = '["Azure AD Premium P1","Conditional Access","Azure AD B2C","RBAC"]'
        CorrectAnswer = 1
        Category = "Identity"
        Difficulty = "Medium"
        Explanation = "Conditional Access allows you to enforce MFA based on specific conditions."
    },
    @{
        Id = "az104-004"
        Question = "Which networking component acts as a firewall at the subnet level?"
        Options = '["Azure Firewall","Network Security Group","Application Gateway","Load Balancer"]'
        CorrectAnswer = 1
        Category = "Networking"
        Difficulty = "Easy"
        Explanation = "Network Security Groups filter traffic at the subnet level based on security rules."
    },
    @{
        Id = "az104-005"
        Question = "What provides centralized logging and monitoring for Azure resources?"
        Options = '["Azure Monitor","Azure Advisor","Azure Service Health","Azure Resource Health"]'
        CorrectAnswer = 0
        Category = "Monitoring"
        Difficulty = "Easy"
        Explanation = "Azure Monitor provides comprehensive monitoring and logging for Azure resources."
    }
)

$successCount = 0

foreach ($q in $questions) {
    try {
        Write-Host "Adding question: $($q.Id)" -ForegroundColor White
        
        az storage entity insert `
            --account-name $StorageAccount `
            --table-name "Questions" `
            --entity "PartitionKey=$ExamType" "RowKey=$($q.Id)" "Id=$($q.Id)" "ExamType=$ExamType" "Category=$($q.Category)" "Difficulty=$($q.Difficulty)" "Question=$($q.Question)" "OptionsJson=$($q.Options)" "CorrectAnswer=$($q.CorrectAnswer)" "Explanation=$($q.Explanation)" `
            --if-exists replace --output none
            
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  Success: $($q.Id)" -ForegroundColor Green
            $successCount++
        } else {
            Write-Host "  Failed: $($q.Id)" -ForegroundColor Red
        }
    } catch {
        Write-Host "  Error: $($q.Id) - $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`nUpload Complete!" -ForegroundColor Cyan
Write-Host "Successful: $successCount / $($questions.Count)" -ForegroundColor White

if ($successCount -gt 0) {
    Write-Host "`nTesting API..." -ForegroundColor Yellow
    try {
        $result = Invoke-RestMethod -Uri "https://azpracticeexam-dev-functions.azurewebsites.net/api/questions/$ExamType" -Method GET
        Write-Host "API returned $($result.Count) questions" -ForegroundColor Green
    } catch {
        Write-Host "API test failed: $($_.Exception.Message)" -ForegroundColor Red
    }
}