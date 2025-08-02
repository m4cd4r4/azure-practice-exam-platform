# Alternative approach - Upload via REST API instead of Azure CLI
param(
    [string]$ExamType = "AZ-104"
)

Write-Host "Creating test question with proper JSON via direct table insertion..." -ForegroundColor Yellow

# Let's try a much simpler approach - just one question with minimal parameters
try {
    # Simple insert with basic parameters only
    $result = az storage entity insert `
        --account-name azpracticeexamdevstorage `
        --table-name "Questions" `
        --entity PartitionKey=$ExamType RowKey=simple-test Id=simple-test Question="Test question" OptionsJson='["Option1","Option2","Option3","Option4"]' CorrectAnswer=1 `
        --if-exists replace 2>&1
        
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Simple question added successfully" -ForegroundColor Green
        
        # Test the API
        Write-Host "Testing API..." -ForegroundColor Yellow
        try {
            $apiResult = Invoke-RestMethod -Uri "https://azpracticeexam-dev-functions.azurewebsites.net/api/questions/$ExamType" -Method GET
            Write-Host "🎉 SUCCESS! API returned $($apiResult.Count) questions" -ForegroundColor Green
            
            if ($apiResult.Count -gt 0) {
                Write-Host "Sample question:" -ForegroundColor Cyan
                $first = $apiResult[0]
                Write-Host "  ID: $($first.id)" -ForegroundColor White
                Write-Host "  Question: $($first.question)" -ForegroundColor White
                Write-Host "  Options: $($first.options -join ', ')" -ForegroundColor White
            }
        } catch {
            Write-Host "❌ API still failing: $($_.Exception.Message)" -ForegroundColor Red
        }
    } else {
        Write-Host "❌ Failed to add question: $result" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
}

# Alternative: Let's check what's actually working by deleting bad records and adding good ones
Write-Host "`nAlternative approach - clearing and re-adding..." -ForegroundColor Yellow

# Delete the problematic records
$problematicIds = @("az104-001", "az104-002", "az104-003", "az104-004", "az104-005")
foreach ($id in $problematicIds) {
    try {
        az storage entity delete --account-name azpracticeexamdevstorage --table-name "Questions" --partition-key $ExamType --row-key $id --if-exists 2>$null
        Write-Host "Deleted $id" -ForegroundColor Gray
    } catch {
        # Ignore errors
    }
}

# Add one working question using the method that worked before
Write-Host "Adding working question..." -ForegroundColor White
try {
    az storage entity insert `
        --account-name azpracticeexamdevstorage `
        --table-name "Questions" `
        --entity PartitionKey=$ExamType RowKey=working-001 Id=working-001 ExamType=$ExamType Category=Test Difficulty=Easy Question="Which Azure service provides Infrastructure as a Service?" OptionsJson="[`"Azure Functions`",`"Azure Virtual Machines`",`"Azure App Service`",`"Azure Logic Apps`"]" CorrectAnswer=1 Explanation="Test explanation" `
        --if-exists replace 2>$null
        
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Working question added" -ForegroundColor Green
        
        # Final API test
        Write-Host "`nFinal API test..." -ForegroundColor Yellow
        try {
            $finalResult = Invoke-RestMethod -Uri "https://azpracticeexam-dev-functions.azurewebsites.net/api/questions/$ExamType" -Method GET
            Write-Host "🎉 FINAL SUCCESS! API returned $($finalResult.Count) questions" -ForegroundColor Green
        } catch {
            Write-Host "❌ Still not working. Let's check the exact JSON format..." -ForegroundColor Red
            
            # Show what we actually stored
            $stored = az storage entity show --account-name azpracticeexamdevstorage --table-name "Questions" --partition-key $ExamType --row-key "working-001" 2>$null | ConvertFrom-Json
            Write-Host "Stored OptionsJson: $($stored.OptionsJson)" -ForegroundColor Yellow
        }
    } else {
        Write-Host "❌ Failed to add working question" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Error adding working question: $($_.Exception.Message)" -ForegroundColor Red
}