# Script to upload questions using temporary JSON files
Write-Host "Uploading Questions to Azure Tables using Azure CLI..." -ForegroundColor Cyan

$storageAccount = "azpracticeexamdevstorage"
$resourceGroup = "rg-azpracticeexam-dev"

# Create table
Write-Host "Creating Questions table..." -ForegroundColor Yellow
az storage table create --name "Questions" --account-name $storageAccount --auth-mode login

# Function to upload a single question using a temporary file
function Upload-Question {
    param(
        $question,
        $questionNumber
    )
    
    Write-Host "Processing question $($questionNumber): $($question.id)" -ForegroundColor Yellow
    
    # Create a proper hashtable for the entity
    $entity = @{
        PartitionKey = $question.examType
        RowKey = $question.id
        Id = $question.id
        ExamType = $question.examType
        Category = $question.category
        Difficulty = $question.difficulty
        Question = $question.question
        OptionsJson = ($question.options | ConvertTo-Json -Compress)
        CorrectAnswer = [int]$question.correctAnswer
        Explanation = $question.explanation
    }
    
    # Create temporary file
    $tempFile = [System.IO.Path]::GetTempFileName()
    
    try {
        # Convert to JSON and save to temporary file
        $entity | ConvertTo-Json -Depth 10 | Out-File -FilePath $tempFile -Encoding UTF8
        
        Write-Host "Uploading: $($question.id)" -ForegroundColor Yellow
        $result = az storage entity insert --account-name $storageAccount --table-name "Questions" --entity "@$tempFile" --auth-mode login --if-exists replace 2>&1
        
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
        Write-Host "Error uploading $($question.id): $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
    finally {
        # Clean up temporary file
        if (Test-Path $tempFile) {
            Remove-Item $tempFile -Force
        }
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

Write-Host "Question upload completed!" -ForegroundColor Green
Write-Host "Total questions processed: $questionCount" -ForegroundColor Cyan
Write-Host "Successful uploads: $successCount" -ForegroundColor Green
Write-Host "Failed uploads: $($questionCount - $successCount)" -ForegroundColor Red
