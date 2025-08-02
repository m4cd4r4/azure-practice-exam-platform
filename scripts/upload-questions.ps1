#Requires -Version 5.1

<#
.SYNOPSIS
    Upload questions to Azure Tables
.DESCRIPTION
    This script uploads question data from JSON files to Azure Tables
.PARAMETER StorageAccountName
    The name of the storage account
.PARAMETER ResourceGroupName
    The name of the resource group
.EXAMPLE
    .\upload-questions.ps1 -StorageAccountName "azpracticeexamdevstorage" -ResourceGroupName "rg-azpracticeexam-dev"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$StorageAccountName,
    
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName
)

Write-Host "🔄 Uploading Questions to Azure Tables..." -ForegroundColor Cyan
Write-Host "Storage Account: $StorageAccountName" -ForegroundColor Yellow
Write-Host "Resource Group: $ResourceGroupName" -ForegroundColor Yellow
Write-Host ""

# Get storage account key
Write-Host "🔑 Getting storage account key..." -ForegroundColor Yellow
$storageKey = (Get-AzStorageAccountKey -ResourceGroupName $ResourceGroupName -Name $StorageAccountName)[0].Value
$ctx = New-AzStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $storageKey

# Create table if it doesn't exist
Write-Host "📝 Creating Questions table..." -ForegroundColor Yellow
$tableName = "Questions"
$table = Get-AzStorageTable -Name $tableName -Context $ctx -ErrorAction SilentlyContinue
if (-not $table) {
    $table = New-AzStorageTable -Name $tableName -Context $ctx
    Write-Host "✅ Table created successfully" -ForegroundColor Green
} else {
    Write-Host "✅ Table already exists" -ForegroundColor Green
}

# Get the CloudTable object for operations
$cloudTable = $table.CloudTable

# Read and upload AZ-104 questions
$az104File = "data/questions/az-104-expanded.json"
if (Test-Path $az104File) {
    Write-Host "📚 Loading AZ-104 questions..." -ForegroundColor Yellow
    $az104Questions = Get-Content $az104File | ConvertFrom-Json
    
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
        }
        
        try {
            Add-AzTableRow -Table $cloudTable -PartitionKey $entity.PartitionKey -RowKey $entity.RowKey -Property $entity -ErrorAction SilentlyContinue
            Write-Host "✅ Uploaded: $($question.id)" -ForegroundColor Green
        } catch {
            Write-Host "⚠️  Question $($question.id) already exists, skipping..." -ForegroundColor Yellow
        }
    }
    
    Write-Host "✅ AZ-104 questions uploaded: $($az104Questions.Count)" -ForegroundColor Green
} else {
    Write-Host "❌ AZ-104 questions file not found: $az104File" -ForegroundColor Red
}

# Read and upload AZ-900 questions
$az900File = "data/questions/az-900-questions.json"
if (Test-Path $az900File) {
    Write-Host "📚 Loading AZ-900 questions..." -ForegroundColor Yellow
    $az900Questions = Get-Content $az900File | ConvertFrom-Json
    
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
        }
        
        try {
            Add-AzTableRow -Table $cloudTable -PartitionKey $entity.PartitionKey -RowKey $entity.RowKey -Property $entity -ErrorAction SilentlyContinue
            Write-Host "✅ Uploaded: $($question.id)" -ForegroundColor Green
        } catch {
            Write-Host "⚠️  Question $($question.id) already exists, skipping..." -ForegroundColor Yellow
        }
    }
    
    Write-Host "✅ AZ-900 questions uploaded: $($az900Questions.Count)" -ForegroundColor Green
} else {
    Write-Host "❌ AZ-900 questions file not found: $az900File" -ForegroundColor Red
}

Write-Host ""
Write-Host "🎉 Question upload completed!" -ForegroundColor Green
Write-Host "🔗 You can view the data in Azure Portal: https://portal.azure.com" -ForegroundColor Cyan
