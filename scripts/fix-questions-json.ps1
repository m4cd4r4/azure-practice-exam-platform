# Fixed Question Upload Script - Properly formats JSON
param(
    [string]$ExamType = "AZ-104"
)

$StorageAccount = "azpracticeexamdevstorage"

Write-Host "Fixing questions with proper JSON formatting..." -ForegroundColor Yellow

# Questions with properly formatted JSON
$questions = @(
    @{
        Id = "az104-fixed-001"
        Question = "Which Azure service provides Infrastructure as a Service?"
        Options = @("Azure Functions", "Azure Virtual Machines", "Azure App Service", "Azure Logic Apps")
        CorrectAnswer = 1
        Category = "Virtual Machines"
        Difficulty = "Easy"
        Explanation = "Azure Virtual Machines provide IaaS with full control over the operating system."
    },
    @{
        Id = "az104-fixed-002"
        Question = "What is the maximum size of a single blob in Azure Blob Storage?"
        Options = @("1 TB", "4.77 TB", "190.7 TB", "500 GB")
        CorrectAnswer = 2
        Category = "Storage"
        Difficulty = "Medium"
        Explanation = "The maximum size for a single blob in Azure Blob Storage is approximately 190.7 TB."
    },
    @{
        Id = "az104-fixed-003"
        Question = "Which Azure AD feature allows you to enforce multi-factor authentication?"
        Options = @("Azure AD Premium P1", "Conditional Access", "Azure AD B2C", "RBAC")
        CorrectAnswer = 1
        Category = "Identity"
        Difficulty = "Medium"
        Explanation = "Conditional Access allows you to enforce MFA based on specific conditions."
    }
)

$successCount = 0

foreach ($q in $questions) {
    try {
        # Convert options to properly formatted JSON
        $optionsJson = $q.Options | ConvertTo-Json -Compress
        
        Write-Host "Adding question: $($q.Id)" -ForegroundColor White
        Write-Host "  Options JSON: $optionsJson" -ForegroundColor Gray
        
        # Use simpler entity format
        $result = az storage entity insert `
            --account-name $StorageAccount `
            --table-name "Questions" `
            --entity PartitionKey=$ExamType RowKey=$($q.Id) Id=$($q.Id) ExamType=$ExamType Category=$($q.Category) Difficulty=$($q.Difficulty) Question="$($q.Question)" OptionsJson="$optionsJson" CorrectAnswer=$($q.CorrectAnswer) Explanation="$($q.Explanation)" `
            --if-exists replace 2>&1
            
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  Success: $($q.Id)" -ForegroundColor Green
            $successCount++
        } else {
            Write-Host "  Failed: $($q.Id) - $result" -ForegroundColor Red
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
        Write-Host "SUCCESS! API returned $($result.Count) questions" -ForegroundColor Green
        
        # Show first question
        if ($result.Count -gt 0) {
            Write-Host "`nFirst question:" -ForegroundColor Cyan
            Write-Host "  Question: $($result[0].question)" -ForegroundColor White
            Write-Host "  Options: $($result[0].options -join ', ')" -ForegroundColor White
        }
    } catch {
        Write-Host "API test failed: $($_.Exception.Message)" -ForegroundColor Red
    }
}