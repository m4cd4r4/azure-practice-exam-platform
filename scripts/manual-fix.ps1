# Manual fix using direct table operations
Write-Host "Manual JSON fix approach..." -ForegroundColor Green

# Step 1: Create a simple test question using insert (not merge)
Write-Host "Creating simple test question..." -ForegroundColor Yellow

try {
    # Use the simplest possible approach
    az storage entity insert `
        --account-name azpracticeexamdevstorage `
        --table-name Questions `
        --entity PartitionKey=AZ-104 RowKey=manual-fix-001 Id=manual-fix-001 ExamType=AZ-104 Question="Test question" CorrectAnswer=1 `
        --if-exists replace --output none
        
    Write-Host "Basic entity created" -ForegroundColor Green
    
    # Step 2: Now manually edit the OptionsJson field using the REST API approach
    Write-Host "Now fixing the OptionsJson field manually..." -ForegroundColor Yellow
    
    # Get the storage account key
    $storageKey = az storage account keys list --account-name azpracticeexamdevstorage --resource-group rg-azpracticeexam-dev --query "[0].value" -o tsv
    
    # Create a connection string
    $connectionString = "DefaultEndpointsProtocol=https;AccountName=azpracticeexamdevstorage;AccountKey=$storageKey;EndpointSuffix=core.windows.net"
    
    Write-Host "Got connection string, now updating entity..." -ForegroundColor White
    
    # Use the connection string to update the entity with proper JSON
    az storage entity merge `
        --connection-string $connectionString `
        --table-name Questions `
        --entity 'PartitionKey=AZ-104' 'RowKey=manual-fix-001' 'OptionsJson=["Option A","Option B","Option C","Option D"]' `
        --output none
        
    Write-Host "Entity updated with proper JSON" -ForegroundColor Green
    
    # Check the result
    $result = az storage entity show `
        --connection-string $connectionString `
        --table-name Questions `
        --partition-key AZ-104 `
        --row-key manual-fix-001 | ConvertFrom-Json
        
    Write-Host "Final OptionsJson: $($result.OptionsJson)" -ForegroundColor Cyan
    
    # Test if it parses as valid JSON
    try {
        $parsedOptions = $result.OptionsJson | ConvertFrom-Json
        Write-Host "SUCCESS! Valid JSON with $($parsedOptions.Count) options:" -ForegroundColor Green
        foreach ($option in $parsedOptions) {
            Write-Host "  - $option" -ForegroundColor White
        }
        
        # Test the API
        Write-Host "`nTesting API..." -ForegroundColor Yellow
        $apiResult = Invoke-RestMethod -Uri "https://azpracticeexam-dev-functions.azurewebsites.net/api/questions/AZ-104" -Method GET
        Write-Host "API SUCCESS! Returned $($apiResult.Count) questions" -ForegroundColor Green
        
        if ($apiResult.Count -gt 0) {
            $first = $apiResult[0]
            Write-Host "First question ID: $($first.id)" -ForegroundColor White
            Write-Host "First question options: $($first.options -join ', ')" -ForegroundColor White
        }
        
    } catch {
        Write-Host "Still not valid JSON: $($_.Exception.Message)" -ForegroundColor Red
    }
    
} catch {
    Write-Host "Error in manual fix: $($_.Exception.Message)" -ForegroundColor Red
}