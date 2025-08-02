# Simple debug script to check Function App issue
Write-Host "Debug Function App Issue" -ForegroundColor Cyan

# Check what's in the database
Write-Host "`n1. Checking database content..." -ForegroundColor Yellow
try {
    $entity = az storage entity show --account-name azpracticeexamdevstorage --table-name "Questions" --partition-key "AZ-104" --row-key "az104-fixed-001" | ConvertFrom-Json
    Write-Host "Question found in database:" -ForegroundColor Green
    Write-Host "   ID: $($entity.Id)" -ForegroundColor White
    Write-Host "   OptionsJson: $($entity.OptionsJson)" -ForegroundColor White
    
    # Test if the JSON is valid
    try {
        $options = $entity.OptionsJson | ConvertFrom-Json
        Write-Host "JSON is valid, contains $($options.Count) options" -ForegroundColor Green
    } catch {
        Write-Host "JSON is invalid: $($_.Exception.Message)" -ForegroundColor Red
    }
} catch {
    Write-Host "Could not read from database: $($_.Exception.Message)" -ForegroundColor Red
}

# Test API with detailed error
Write-Host "`n2. Getting detailed API error..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "https://azpracticeexam-dev-functions.azurewebsites.net/api/questions/AZ-104" -Method GET
    Write-Host "Unexpected success: $($response.StatusCode)" -ForegroundColor Green
} catch {
    Write-Host "API Error Details:" -ForegroundColor Red
    Write-Host "   Status: $($_.Exception.Response.StatusCode)" -ForegroundColor White
    
    try {
        $stream = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($stream)
        $responseBody = $reader.ReadToEnd()
        Write-Host "   Body: $responseBody" -ForegroundColor White
    } catch {
        Write-Host "   Could not read response body" -ForegroundColor Gray
    }
}

# Test health endpoint
Write-Host "`n3. Testing health endpoint..." -ForegroundColor Yellow
try {
    $health = Invoke-RestMethod -Uri "https://azpracticeexam-dev-functions.azurewebsites.net/api/health" -Method GET
    Write-Host "Health check passed: $($health.status)" -ForegroundColor Green
} catch {
    Write-Host "Health check failed: $($_.Exception.Message)" -ForegroundColor Red
}