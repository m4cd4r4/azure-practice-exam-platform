# Fixed script to upload questions using Azure CLI
Write-Host "Uploading Questions to Azure Tables using Azure CLI..." -ForegroundColor Cyan

$storageAccount = "azpracticeexamdevstorage"
$resourceGroup = "rg-azpracticeexam-dev"

# Create table
Write-Host "Creating Questions table..." -ForegroundColor Yellow
az storage table create --name "Questions" --account-name $storageAccount --auth-mode login

# Function to safely escape JSON strings
function Escape-JsonString {
    param([string]$InputString)
    if (-not $InputString) { return "" }
    return $InputString -replace '"', '\"' -replace '\n', '\n' -replace '\r', '\r' -replace '\t', '\t' -replace '\\', '\\'
}

# Upload AZ-104 questions
Write-Host "Loading AZ-104 questions..." -ForegroundColor Yellow
$az104Questions = Get-Content "../data/questions/az-104-expanded.json" -Raw | ConvertFrom-Json

$questionCount = 0
foreach ($question in $az104Questions) {
    $questionCount++
    Write-Host "Processing question $questionCount`: $($question.id)" -ForegroundColor Yellow
    
    # Convert options array to JSON string and escape properly
    $optionsJson = ($question.options | ConvertTo-Json -Compress) -replace '"', '\"'
    
    # Escape text fields
    $questionText = Escape-JsonString $question.question
    $explanationText = Escape-JsonString $question.explanation
    $categoryText = Escape-JsonString $question.category
    $difficultyText = Escape-JsonString $question.difficulty
    
    # Create entity JSON manually to ensure proper formatting
    $entityJson = @"
{
    "PartitionKey": "$($question.examType)",
    "RowKey": "$($question.id)",
    "Id": "$($question.id)",
    "ExamType": "$($question.examType)",
    "Category": "$categoryText",
    "Difficulty": "$difficultyText",
    "Question": "$questionText",
    "OptionsJson": "$optionsJson",
    "CorrectAnswer": $($question.correctAnswer),
    "Explanation": "$explanationText"
}
"@
    
    try {
        Write-Host "Uploading: $($question.id)" -ForegroundColor Yellow
        az storage entity insert --account-name $storageAccount --table-name "Questions" --entity $entityJson --auth-mode login --if-exists replace
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✓ Successfully uploaded: $($question.id)" -ForegroundColor Green
        } else {
            Write-Host "✗ Failed to upload: $($question.id)" -ForegroundColor Red
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
    Write-Host "Processing question $questionCount`: $($question.id)" -ForegroundColor Yellow
    
    # Convert options array to JSON string and escape properly
    $optionsJson = ($question.options | ConvertTo-Json -Compress) -replace '"', '\"'
    
    # Escape text fields
    $questionText = Escape-JsonString $question.question
    $explanationText = Escape-JsonString $question.explanation
    $categoryText = Escape-JsonString $question.category
    $difficultyText = Escape-JsonString $question.difficulty
    
    # Create entity JSON manually to ensure proper formatting
    $entityJson = @"
{
    "PartitionKey": "$($question.examType)",
    "RowKey": "$($question.id)",
    "Id": "$($question.id)",
    "ExamType": "$($question.examType)",
    "Category": "$categoryText",
    "Difficulty": "$difficultyText",
    "Question": "$questionText",
    "OptionsJson": "$optionsJson",
    "CorrectAnswer": $($question.correctAnswer),
    "Explanation": "$explanationText"
}
"@
    
    try {
        Write-Host "Uploading: $($question.id)" -ForegroundColor Yellow
        az storage entity insert --account-name $storageAccount --table-name "Questions" --entity $entityJson --auth-mode login --if-exists replace
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✓ Successfully uploaded: $($question.id)" -ForegroundColor Green
        } else {
            Write-Host "✗ Failed to upload: $($question.id)" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "Error uploading $($question.id): $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "Question upload completed! Total questions processed: $questionCount" -ForegroundColor Green
