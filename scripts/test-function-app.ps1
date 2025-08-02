# Test if the issue is the Function App code itself
Write-Host "Testing Function App connectivity..." -ForegroundColor Cyan

# Create the absolute simplest possible question
Write-Host "Creating minimal test question..." -ForegroundColor Yellow

try {
    # Super simple entity with no complex JSON
    az storage entity insert `
        --account-name azpracticeexamdevstorage `
        --table-name Questions `
        --entity PartitionKey=AZ-104 RowKey=simple Id=simple ExamType=AZ-104 Question="Simple test" OptionsJson="test" CorrectAnswer=0 Category=Test Difficulty=Easy Explanation=Test `
        --if-exists replace --output none
        
    Write-Host "Simple entity created" -ForegroundColor Green
    
    # Verify it exists
    $simple = az storage entity show --account-name azpracticeexamdevstorage --table-name Questions --partition-key AZ-104 --row-key simple | ConvertFrom-Json
    Write-Host "Simple entity verified: $($simple.Question)" -ForegroundColor Green
    
    # Test API
    Write-Host "Testing API with simple entity..." -ForegroundColor Yellow
    try {
        $apiResult = Invoke-RestMethod -Uri "https://azpracticeexam-dev-functions.azurewebsites.net/api/questions/AZ-104" -Method GET
        Write-Host "API SUCCESS! Even with simple entity, API works." -ForegroundColor Green
        Write-Host "This means the JSON deserialization is the issue." -ForegroundColor Yellow
    } catch {
        Write-Host "API FAILED even with simple entity." -ForegroundColor Red
        Write-Host "This means the Function App has a deeper issue." -ForegroundColor Yellow
        
        # Let's check if it's a case sensitivity issue
        Write-Host "Testing case sensitivity..." -ForegroundColor White
        try {
            $caseTest = Invoke-RestMethod -Uri "https://azpracticeexam-dev-functions.azurewebsites.net/api/questions/az-104" -Method GET
            Write-Host "Lowercase worked!" -ForegroundColor Green
        } catch {
            Write-Host "Lowercase also failed" -ForegroundColor Red
        }
    }
    
} catch {
    Write-Host "Failed to create simple entity: $($_.Exception.Message)" -ForegroundColor Red
}

# Show what's actually in the database
Write-Host "`nChecking all questions in database..." -ForegroundColor Yellow
try {
    $allQuestions = az storage entity query --account-name azpracticeexamdevstorage --table-name Questions --filter "PartitionKey eq 'AZ-104'" --select Id,Question | ConvertFrom-Json
    Write-Host "Found $($allQuestions.items.Count) questions in database:" -ForegroundColor Green
    foreach ($q in $allQuestions.items) {
        Write-Host "  - $($q.Id): $($q.Question)" -ForegroundColor White
    }
} catch {
    Write-Host "Could not query database: $($_.Exception.Message)" -ForegroundColor Red
}