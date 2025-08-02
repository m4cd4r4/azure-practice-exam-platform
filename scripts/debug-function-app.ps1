# Debug the Function App issue
Write-Host "🔍 Debugging Function App Issue" -ForegroundColor Cyan

# Test 1: Check what's in the database
Write-Host "`n1. Checking database content..." -ForegroundColor Yellow
try {
    $entity = az storage entity show --account-name azpracticeexamdevstorage --table-name "Questions" --partition-key "AZ-104" --row-key "az104-fixed-001" | ConvertFrom-Json
    Write-Host "✅ Question found in database:" -ForegroundColor Green
    Write-Host "   ID: $($entity.Id)" -ForegroundColor White
    Write-Host "   Question: $($entity.Question)" -ForegroundColor White
    Write-Host "   OptionsJson: $($entity.OptionsJson)" -ForegroundColor White
    Write-Host "   CorrectAnswer: $($entity.CorrectAnswer)" -ForegroundColor White
    
    # Test if the JSON is valid
    try {
        $options = $entity.OptionsJson | ConvertFrom-Json
        Write-Host "✅ JSON is valid, contains $($options.Count) options:" -ForegroundColor Green
        foreach ($option in $options) {
            Write-Host "     - $option" -ForegroundColor Gray
        }
    } catch {
        Write-Host "❌ JSON is invalid: $($_.Exception.Message)" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Could not read from database: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 2: Check Function App configuration
Write-Host "`n2. Checking Function App configuration..." -ForegroundColor Yellow
try {
    $settings = az functionapp config appsettings list --name azpracticeexam-dev-functions --resource-group rg-azpracticeexam-dev --query "[?name=='AzureWebJobsStorage']" | ConvertFrom-Json
    if ($settings) {
        Write-Host "✅ AzureWebJobsStorage is configured" -ForegroundColor Green
    } else {
        Write-Host "❌ AzureWebJobsStorage not found" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Could not check Function App settings" -ForegroundColor Red
}

# Test 3: Simple API call with detailed error
Write-Host "`n3. Getting detailed API error..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "https://azpracticeexam-dev-functions.azurewebsites.net/api/questions/AZ-104" -Method GET
    Write-Host "✅ Unexpected success: $($response.StatusCode)" -ForegroundColor Green
} catch {
    Write-Host "❌ API Error Details:" -ForegroundColor Red
    Write-Host "   Status: $($_.Exception.Response.StatusCode)" -ForegroundColor White
    Write-Host "   Description: $($_.Exception.Response.StatusDescription)" -ForegroundColor White
    
    # Try to get response body
    try {
        $stream = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($stream)
        $responseBody = $reader.ReadToEnd()
        Write-Host "   Body: $responseBody" -ForegroundColor White
    } catch {
        Write-Host "   Could not read response body" -ForegroundColor Gray
    }
}

# Test 4: Try a simple health check
Write-Host "`n4. Testing health endpoint..." -ForegroundColor Yellow
try {
    $health = Invoke-RestMethod -Uri "https://azpracticeexam-dev-functions.azurewebsites.net/api/health" -Method GET
    Write-Host "✅ Health check passed: $($health.status)" -ForegroundColor Green
} catch {
    Write-Host "❌ Health check failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 5: Check if there's a different issue
Write-Host "`n5. Checking table connectivity..." -ForegroundColor Yellow
try {
    $tableExists = az storage table exists --name "Questions" --account-name azpracticeexamdevstorage | ConvertFrom-Json
    if ($tableExists.exists) {
        Write-Host "✅ Questions table exists" -ForegroundColor Green
        
        $count = az storage entity query --account-name azpracticeexamdevstorage --table-name "Questions" --filter "PartitionKey eq 'AZ-104'" --select "Id" | ConvertFrom-Json
        Write-Host "✅ Found $($count.items.Count) AZ-104 questions in table" -ForegroundColor Green
    } else {
        Write-Host "❌ Questions table does not exist" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Could not check table: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n🎯 Summary:" -ForegroundColor Cyan
Write-Host "If the database contains valid JSON but the API still fails," -ForegroundColor White
Write-Host "the issue is likely in the Function App code or configuration." -ForegroundColor White