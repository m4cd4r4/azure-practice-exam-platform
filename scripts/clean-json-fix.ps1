# Clean script to fix JSON formatting issue
Write-Host "Fixing JSON format issue..." -ForegroundColor Green

# Create a simple entity with properly formatted JSON
Write-Host "Creating entity with correct JSON..." -ForegroundColor Yellow

# Method 1: Use PowerShell to create proper JSON string
$optionsArray = @("Azure Functions", "Azure Virtual Machines", "Azure App Service", "Azure Logic Apps")
$optionsJson = $optionsArray | ConvertTo-Json -Compress

Write-Host "Proper JSON format: $optionsJson" -ForegroundColor Cyan

# Method 2: Manual approach with escaped quotes
$manualJson = '["Azure Functions","Azure Virtual Machines","Azure App Service","Azure Logic Apps"]'
Write-Host "Manual JSON format: $manualJson" -ForegroundColor Cyan

# Try using az storage entity merge instead of insert
Write-Host "Attempting to create entity..." -ForegroundColor White

try {
    # Create entity using merge (which handles JSON better)
    az storage entity merge `
        --account-name azpracticeexamdevstorage `
        --table-name Questions `
        --entity PartitionKey=AZ-104 RowKey=correct-json-001 Id=correct-json-001 ExamType=AZ-104 Category=Test Difficulty=Easy Question="Test with correct JSON" CorrectAnswer=1 Explanation="Test" `
        --if-not-exists

    Write-Host "Entity created, now updating with correct JSON..." -ForegroundColor White
    
    # Update just the OptionsJson field
    az storage entity merge `
        --account-name azpracticeexamdevstorage `
        --table-name Questions `
        --entity PartitionKey=AZ-104 RowKey=correct-json-001 OptionsJson="$manualJson"
        
    Write-Host "JSON field updated" -ForegroundColor Green
    
    # Check what was stored
    Write-Host "Checking stored data..." -ForegroundColor Yellow
    $result = az storage entity show --account-name azpracticeexamdevstorage --table-name Questions --partition-key AZ-104 --row-key correct-json-001 | ConvertFrom-Json
    
    Write-Host "Stored OptionsJson: $($result.OptionsJson)" -ForegroundColor Cyan
    
    # Test if it's valid JSON
    try {
        $testParse = $result.OptionsJson | ConvertFrom-Json
        Write-Host "SUCCESS! JSON is valid and contains $($testParse.Count) options" -ForegroundColor Green
        
        # Now test the API
        Write-Host "Testing API..." -ForegroundColor Yellow
        $apiResult = Invoke-RestMethod -Uri "https://azpracticeexam-dev-functions.azurewebsites.net/api/questions/AZ-104" -Method GET
        Write-Host "API SUCCESS! Returned $($apiResult.Count) questions" -ForegroundColor Green
        
    } catch {
        Write-Host "JSON parsing failed: $($_.Exception.Message)" -ForegroundColor Red
    }
    
} catch {
    Write-Host "Failed to create/update entity: $($_.Exception.Message)" -ForegroundColor Red
}