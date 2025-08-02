# Final fix - Create question with absolutely correct JSON format
Write-Host "🔧 Creating question with perfect JSON format..." -ForegroundColor Cyan

# Method: Create a JSON file and upload it properly
$question = @{
    PartitionKey = "AZ-104"
    RowKey = "working-question-001"
    Id = "working-question-001"
    ExamType = "AZ-104"
    Category = "Virtual Machines"
    Difficulty = "Easy"
    Question = "Which Azure service provides Infrastructure as a Service?"
    OptionsJson = '["Azure Functions","Azure Virtual Machines","Azure App Service","Azure Logic Apps"]'
    CorrectAnswer = 1
    Explanation = "Azure Virtual Machines provide IaaS with full control over the operating system."
}

Write-Host "Target JSON format: $($question.OptionsJson)" -ForegroundColor Yellow

# Try direct approach with proper escaping
Write-Host "`nAttempting upload with proper JSON escaping..." -ForegroundColor White

try {
    # Use az storage entity merge with individual parameters
    $cmd = "az storage entity merge --account-name azpracticeexamdevstorage --table-name Questions --entity"
    $entity = 'PartitionKey="AZ-104" RowKey="test-json-001" Id="test-json-001" ExamType="AZ-104" Category="Test" Difficulty="Easy" Question="Test question" OptionsJson="[""Option A"",""Option B"",""Option C"",""Option D""]" CorrectAnswer="1" Explanation="Test"'
    
    Write-Host "Command: $cmd $entity" -ForegroundColor Gray
    
    # Execute
    $result = Invoke-Expression "$cmd $entity" 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Success with merge approach!" -ForegroundColor Green
        
        # Check what was actually stored
        $stored = az storage entity show --account-name azpracticeexamdevstorage --table-name "Questions" --partition-key "AZ-104" --row-key "test-json-001" | ConvertFrom-Json
        Write-Host "Stored OptionsJson: $($stored.OptionsJson)" -ForegroundColor Cyan
        
        # Test API
        Write-Host "`nTesting API..." -ForegroundColor Yellow
        try {
            $apiResult = Invoke-RestMethod -Uri "https://azpracticeexam-dev-functions.azurewebsites.net/api/questions/AZ-104" -Method GET
            Write-Host "🎉 SUCCESS! API returned $($apiResult.Count) questions" -ForegroundColor Green
            
            if ($apiResult.Count -gt 0) {
                $first = $apiResult[0]
                Write-Host "First question options: $($first.options -join ', ')" -ForegroundColor White
            }
        } catch {
            Write-Host "❌ API still failing: $($_.Exception.Message)" -ForegroundColor Red
        }
    } else {
        Write-Host "❌ Merge failed: $result" -ForegroundColor Red
        
        # Try the direct REST API approach
        Write-Host "`nTrying REST API approach..." -ForegroundColor White
        
        # Get storage account key
        $keys = az storage account keys list --account-name azpracticeexamdevstorage --resource-group rg-azpracticeexam-dev | ConvertFrom-Json
        $key = $keys[0].value
        
        Write-Host "Got storage key, creating entity via REST..." -ForegroundColor Gray
        
        # Create entity with proper JSON via PowerShell
        $storageAccount = "azpracticeexamdevstorage"
        $tableName = "Questions"
        $partitionKey = "AZ-104"
        $rowKey = "rest-api-001"
        
        # Create the entity object with proper JSON
        $entity = @{
            PartitionKey = $partitionKey
            RowKey = $rowKey
            Id = $rowKey
            ExamType = "AZ-104"
            Category = "Test"
            Difficulty = "Easy"
            Question = "Which Azure service provides Infrastructure as a Service?"
            OptionsJson = '["Azure Functions","Azure Virtual Machines","Azure App Service","Azure Logic Apps"]'
            CorrectAnswer = 1
            Explanation = "Azure Virtual Machines provide IaaS."
        }
        
        Write-Host "Creating entity with perfect JSON: $($entity.OptionsJson)" -ForegroundColor Cyan
        
        # Use Azure PowerShell approach instead
        $entityJson = $entity | ConvertTo-Json
        Write-Host "Entity JSON: $entityJson" -ForegroundColor Gray
        
        # Simple approach: write to temp file and use az storage entity insert with file
        $tempFile = "temp-entity.json"
        $entity | ConvertTo-Json | Out-File -FilePath $tempFile -Encoding UTF8
        
        try {
            $fileResult = az storage entity insert --account-name $storageAccount --table-name $tableName --entity "@$tempFile" --if-exists replace 2>&1
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host "✅ File-based insert succeeded!" -ForegroundColor Green
                
                # Check result
                $finalCheck = az storage entity show --account-name $storageAccount --table-name $tableName --partition-key $partitionKey --row-key $rowKey | ConvertFrom-Json
                Write-Host "Final OptionsJson: $($finalCheck.OptionsJson)" -ForegroundColor Cyan
                
                # Final API test
                Write-Host "`nFinal API test..." -ForegroundColor Yellow
                try {
                    $finalApiResult = Invoke-RestMethod -Uri "https://azpracticeexam-dev-functions.azurewebsites.net/api/questions/AZ-104" -Method GET
                    Write-Host "🎉 FINAL SUCCESS! API returned $($finalApiResult.Count) questions" -ForegroundColor Green
                } catch {
                    Write-Host "❌ API still not working. The issue may be in the Function App code itself." -ForegroundColor Red
                }
            } else {
                Write-Host "❌ File-based insert failed: $fileResult" -ForegroundColor Red
            }
        } finally {
            Remove-Item $tempFile -ErrorAction SilentlyContinue
        }
    }
} catch {
    Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
}