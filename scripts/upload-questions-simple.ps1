# Simple script to upload questions using Azure CLI with proper JSON handling
Write-Host "Uploading Questions to Azure Tables using Azure CLI..." -ForegroundColor Cyan

$storageAccount = "azpracticeexamdevstorage"
$resourceGroup = "rg-azpracticeexam-dev"

# Create table
Write-Host "Creating Questions table..." -ForegroundColor Yellow
az storage table create --name "Questions" --account-name $storageAccount --auth-mode login

# Upload AZ-104 questions
Write-Host "Loading AZ-104 questions..." -ForegroundColor Yellow
$az104Questions = Get-Content "../data/questions/az-104-expanded.json" -Raw | ConvertFrom-Json

$questionCount = 0
foreach ($question in $az104Questions) {
    $questionCount++
    Write-Host "Processing question $($questionCount): $($question.id)" -ForegroundColor Yellow
    
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
    
    # Convert to JSON with proper escaping
    $entityJson = $entity | ConvertTo-Json -Compress
    
    try {
        Write-Host "Uploading: $($question.id)" -ForegroundColor Yellow
        $result = az storage entity insert --account-name $storageAccount --table-name "Questions" --entity $entityJson --auth-mode login --if-exists replace 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Successfully uploaded: $($question.id)" -ForegroundColor Green
        } else {
            Write-Host "Failed to upload: $($question.id) - $result" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "Error uploading $($question.id): $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Upload AZ-900 questions  
Write-Host "Loading AZ-900 questions..." -ForegroundColor Yellow
$az900Questions = Get-Content "../data/questions/az-900-questions.json" -Raw | ConvertFrom-Json

foreach ($question in $az900Questions) {
    $questionCount++
    Write-Host "Processing question $($questionCount): $($question.id)" -ForegroundColor Yellow
    
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
    
    # Convert to JSON with proper escaping
    $entityJson = $entity | ConvertTo-Json -Compress
    
    try {
        Write-Host "Uploading: $($question.id)" -ForegroundColor Yellow
        $result = az storage entity insert --account-name $storageAccount --table-name "Questions" --entity $entityJson --auth-mode login --if-exists replace 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Successfully uploaded: $($question.id)" -ForegroundColor Green
        } else {
            Write-Host "Failed to upload: $($question.id) - $result" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "Error uploading $($question.id): $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "Question upload completed! Total questions processed: $questionCount" -ForegroundColor Green
