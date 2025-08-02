# Simple script to upload questions - no complex escaping
Write-Host "Uploading Questions to Azure Tables..." -ForegroundColor Cyan

$storageAccount = "azpracticeexamdevstorage"

# Create table
Write-Host "Creating Questions table..." -ForegroundColor Yellow
az storage table create --name "Questions" --account-name $storageAccount --auth-mode key

# Upload first few AZ-104 questions as test
Write-Host "Loading AZ-104 questions..." -ForegroundColor Yellow
$az104Questions = Get-Content "../data/questions/az-104-expanded.json" -Raw | ConvertFrom-Json

$count = 0
$successCount = 0

# Upload only first 5 questions as test
foreach ($question in $az104Questions[0..4]) {
    $count++
    Write-Host "Uploading question $count`: $($question.id)" -ForegroundColor Yellow
    
    $optionsJson = $question.options | ConvertTo-Json -Compress
    
    $cmd = "az storage entity insert --account-name $storageAccount --table-name Questions --auth-mode key --if-exists replace --entity"
    $cmd += " `"PartitionKey=$($question.examType)`""
    $cmd += " `"RowKey=$($question.id)`""
    $cmd += " `"Id=$($question.id)`""
    $cmd += " `"ExamType=$($question.examType)`""
    $cmd += " `"Category=$($question.category)`""
    $cmd += " `"Difficulty=$($question.difficulty)`""
    $cmd += " `"Question=$($question.question)`""
    $cmd += " `"OptionsJson=$optionsJson`""
    $cmd += " `"CorrectAnswer=$($question.correctAnswer)`""
    $cmd += " `"Explanation=$($question.explanation)`""
    
    $result = Invoke-Expression $cmd 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Success: $($question.id)" -ForegroundColor Green
        $successCount++
    } else {
        Write-Host "Failed: $($question.id)" -ForegroundColor Red
        Write-Host "Error: $result" -ForegroundColor Red
    }
}

Write-Host "Test upload completed!" -ForegroundColor Green
Write-Host "Total: $count, Success: $successCount, Failed: $($count - $successCount)"
