# Simple script to upload questions using Azure CLI
Write-Host "Uploading Questions to Azure Tables using Azure CLI..." -ForegroundColor Cyan

$storageAccount = "azpracticeexamdevstorage"
$resourceGroup = "rg-azpracticeexam-dev"

# Create table
Write-Host "Creating Questions table..." -ForegroundColor Yellow
az storage table create --name "Questions" --account-name $storageAccount --auth-mode login

# Upload AZ-104 questions
Write-Host "Loading AZ-104 questions..." -ForegroundColor Yellow
$az104Questions = Get-Content "../data/questions/az-104-expanded.json" | ConvertFrom-Json

foreach ($question in $az104Questions) {
    $entity = @{
        PartitionKey = $question.examType
        RowKey = $question.id
        Id = $question.id
        ExamType = $question.examType
        Category = $question.category
        Difficulty = $question.difficulty
        Question = $question.question
        OptionsJson = ($question.options | ConvertTo-Json -Compress)
        CorrectAnswer = $question.correctAnswer
        Explanation = $question.explanation
    } | ConvertTo-Json -Compress
    
    Write-Host "Uploading: $($question.id)" -ForegroundColor Yellow
    az storage entity insert --account-name $storageAccount --table-name "Questions" --entity $entity --auth-mode login --if-exists replace
}

# Upload AZ-900 questions  
Write-Host "Loading AZ-900 questions..." -ForegroundColor Yellow
$az900Questions = Get-Content "../data/questions/az-900-questions.json" | ConvertFrom-Json

foreach ($question in $az900Questions) {
    $entity = @{
        PartitionKey = $question.examType
        RowKey = $question.id
        Id = $question.id
        ExamType = $question.examType
        Category = $question.category
        Difficulty = $question.difficulty
        Question = $question.question
        OptionsJson = ($question.options | ConvertTo-Json -Compress)
        CorrectAnswer = $question.correctAnswer
        Explanation = $question.explanation
    } | ConvertTo-Json -Compress
    
    Write-Host "Uploading: $($question.id)" -ForegroundColor Yellow
    az storage entity insert --account-name $storageAccount --table-name "Questions" --entity $entity --auth-mode login --if-exists replace
}

Write-Host "Question upload completed!" -ForegroundColor Green
