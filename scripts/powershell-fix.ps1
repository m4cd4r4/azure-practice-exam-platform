# PowerShell-only approach to create proper JSON
Write-Host "Using PowerShell direct approach..." -ForegroundColor Green

# Since Azure CLI keeps stripping quotes, let's use PowerShell with REST API directly
$storageAccountName = "azpracticeexamdevstorage"
$tableName = "Questions"

# Get storage account key
$storageKey = az storage account keys list --account-name $storageAccountName --resource-group rg-azpracticeexam-dev --query "[0].value" -o tsv

Write-Host "Got storage key: $($storageKey.Substring(0,10))..." -ForegroundColor Gray

# Create the proper JSON manually (the way the Function App expects it)
$properOptionsJson = '["Azure Functions","Azure Virtual Machines","Azure App Service","Azure Logic Apps"]'

Write-Host "Target JSON: $properOptionsJson" -ForegroundColor Cyan

# Test that our JSON is valid
try {
    $testParse = $properOptionsJson | ConvertFrom-Json
    Write-Host "Our JSON is valid with $($testParse.Count) options" -ForegroundColor Green
} catch {
    Write-Host "Our JSON is invalid: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Method: Use Azure PowerShell Az modules if available, or REST API
Write-Host "Checking if Az.Storage module is available..." -ForegroundColor Yellow

try {
    Import-Module Az.Storage -ErrorAction Stop
    Write-Host "Az.Storage module found, using PowerShell approach..." -ForegroundColor Green
    
    # Create storage context
    $ctx = New-AzStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageKey
    
    # Create the entity object
    $entity = @{
        PartitionKey = "AZ-104"
        RowKey = "powershell-001"
        Id = "powershell-001"
        ExamType = "AZ-104"
        Category = "Test"
        Difficulty = "Easy"
        Question = "Which Azure service provides Infrastructure as a Service?"
        OptionsJson = $properOptionsJson
        CorrectAnswer = 1
        Explanation = "Azure Virtual Machines provide IaaS."
    }
    
    # Add entity using PowerShell
    Add-AzTableRow -Table (Get-AzStorageTable -Name $tableName -Context $ctx).CloudTable -Entity $entity -UpdateExisting
    
    Write-Host "Entity created via PowerShell!" -ForegroundColor Green
    
    # Verify what was stored
    $stored = az storage entity show --account-name $storageAccountName --table-name $tableName --partition-key "AZ-104" --row-key "powershell-001" | ConvertFrom-Json
    Write-Host "PowerShell result - OptionsJson: $($stored.OptionsJson)" -ForegroundColor Cyan
    
    # Test if it's valid
    try {
        $powershellTest = $stored.OptionsJson | ConvertFrom-Json
        Write-Host "SUCCESS! PowerShell created valid JSON with $($powershellTest.Count) options" -ForegroundColor Green
        
        # Test API
        Write-Host "Testing API..." -ForegroundColor Yellow
        $apiResult = Invoke-RestMethod -Uri "https://azpracticeexam-dev-functions.azurewebsites.net/api/questions/AZ-104" -Method GET
        Write-Host "API SUCCESS! Returned $($apiResult.Count) questions" -ForegroundColor Green
        
    } catch {
        Write-Host "PowerShell JSON still invalid: $($_.Exception.Message)" -ForegroundColor Red
    }
    
} catch {
    Write-Host "Az.Storage module not available, trying alternative..." -ForegroundColor Yellow
    
    # Alternative: Let's manually create the entity with a completely different approach
    Write-Host "Using direct file approach..." -ForegroundColor White
    
    # Create a batch file that does the insertion
    $batchContent = @"
{
  "PartitionKey": "AZ-104",
  "RowKey": "file-based-001",
  "Id": "file-based-001",
  "ExamType": "AZ-104",
  "Category": "Test",
  "Difficulty": "Easy",
  "Question": "Which Azure service provides Infrastructure as a Service?",
  "OptionsJson": "[\\"Azure Functions\\",\\"Azure Virtual Machines\\",\\"Azure App Service\\",\\"Azure Logic Apps\\"]",
  "CorrectAnswer": 1,
  "Explanation": "Azure Virtual Machines provide IaaS."
}
"@
    
    $batchFile = "entity.json"
    $batchContent | Out-File -FilePath $batchFile -Encoding UTF8
    
    Write-Host "Created entity file with proper JSON escaping" -ForegroundColor Green
    Write-Host "File content includes: OptionsJson with escaped quotes" -ForegroundColor Gray
    
    # Try to insert using the file
    try {
        az storage entity insert --account-name $storageAccountName --table-name $tableName --entity "@$batchFile" --if-exists replace
        
        Write-Host "File-based insert completed" -ForegroundColor Green
        
        # Check result
        $fileResult = az storage entity show --account-name $storageAccountName --table-name $tableName --partition-key "AZ-104" --row-key "file-based-001" | ConvertFrom-Json
        Write-Host "File result - OptionsJson: $($fileResult.OptionsJson)" -ForegroundColor Cyan
        
        # Test API
        Write-Host "Testing API with file-based entity..." -ForegroundColor Yellow
        try {
            $apiFileTest = Invoke-RestMethod -Uri "https://azpracticeexam-dev-functions.azurewebsites.net/api/questions/AZ-104" -Method GET
            Write-Host "API SUCCESS! Returned $($apiFileTest.Count) questions" -ForegroundColor Green
        } catch {
            Write-Host "API still failing: $($_.Exception.Message)" -ForegroundColor Red
        }
        
    } catch {
        Write-Host "File-based insert failed: $($_.Exception.Message)" -ForegroundColor Red
    } finally {
        Remove-Item $batchFile -ErrorAction SilentlyContinue
    }
}

Write-Host "`nIf all approaches fail, the issue is likely in the Function App code itself." -ForegroundColor Yellow