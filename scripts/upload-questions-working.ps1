# Script to upload questions using key authentication
Write-Host "Uploading Questions to Azure Tables using Azure CLI..." -ForegroundColor Cyan

$storageAccount = "azpracticeexamdevstorage"
$resourceGroup = "rg-azpracticeexam-dev"

# Create table
Write-Host "Creating Questions table..." -ForegroundColor Yellow
az storage table create --name "Questions" --account-name $storageAccount --auth-mode key

# Function to upload a single question
function Upload-Question {
    param(
        $question,
        $questionNumber
    )
    
    Write-Host "Processing question $($questionNumber): $($question.id)" -ForegroundColor Yellow
    
    # Escape special characters for command line
    $questionText = $question.question -replace '"', '\"' -replace "'", "''"
    $explanationText = $question.explanation -replace '"', '\"' -replace "'", "''"
    $categoryText = $question.category -replace '"', '\"'
    $difficultyText = $question.difficulty -replace '"', '\"'
    $optionsJson = ($question.options | ConvertTo-Json -Compress) -replace '"', '\"'
    
    try {
        Write-Host "Uploading: $($question.id)" -ForegroundColor Yellow
        
        # Use individual property assignments with key auth
        $result = az storage entity insert `
            --account-name $storageAccount `
            --table-name "Questions" `
            --entity `
                "PartitionKey=$($question.examType)" `
                "RowKey=$($question.id)" `
                "Id=$($question.id)" `
                "ExamType=$($question.examType)" `
                "Category=$categoryText" `
                "Difficulty=$difficultyText" `
                "Question=$questionText" `
                "OptionsJson=$optionsJson" `
                "CorrectAnswer=$($question.correctAnswer)" `
                "Explanation=$explanationText" `
            --auth-mode key `
            --if-exists replace 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✓ Successfully uploaded: $($question.id)" -ForegroundColor Green
            return $true
        } else {
            Write-Host "✗ Failed to upload: $($question.id)" -ForegroundColor Red
            Write-Host "Error: $result" -ForegroundColor Red
            return $false
        }
    }
    catch {
        Write-Host "✗ Error uploading $($question.id): $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Upload AZ-104 questions
Write-Host "Loading AZ-104 questions..." -ForegroundColor Yellow
$az104Questions = Get-Content "../data/questions/az-104-expanded.json" -Raw | ConvertFrom-Json

$questionCount = 0
$successCount = 0

foreach ($question in $az104Questions) {
    $questionCount++
    if (Upload-Question $question $questionCount) {
        $successCount++
    }
}

# Upload AZ-900 questions  
Write-Host "Loading AZ-900 questions..." -ForegroundColor Yellow
$az900Questions = Get-Content "../data/questions/az-900-questions.json" -Raw | ConvertFrom-Json

foreach ($question in $az900Questions) {
    $questionCount++
    if (Upload-Question $question $questionCount) {
        $successCount++
    }
}

Write-Host "===========================================" -ForegroundColor Cyan
Write-Host "Question upload completed!" -ForegroundColor Green
Write-Host "Total questions processed: $questionCount" -ForegroundColor Cyan
Write-Host "Successful uploads: $successCount" -ForegroundColor Green
Write-Host "Failed uploads: $($questionCount - $successCount)" -ForegroundColor Red
Write-Host "===========================================" -ForegroundColor Cyan
