# Simple API Test Script for Azure Practice Exam Platform
param(
    [string]$BaseUrl = "https://azpracticeexam-dev-functions.azurewebsites.net/api",
    [string]$ExamType = "AZ-104"
)

Write-Host "Testing Azure Practice Exam API" -ForegroundColor Cyan
Write-Host "Base URL: $BaseUrl" -ForegroundColor White
Write-Host "Exam Type: $ExamType" -ForegroundColor White
Write-Host ""

# Test 1: Health Check
Write-Host "1. Testing Health Endpoint..." -ForegroundColor Yellow
try {
    $health = Invoke-RestMethod -Uri "$BaseUrl/health" -Method GET -TimeoutSec 10
    Write-Host "   Success: $($health.status)" -ForegroundColor Green
} catch {
    Write-Host "   Failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 2: Questions Endpoint
Write-Host "`n2. Testing Questions Endpoint..." -ForegroundColor Yellow
try {
    $questions = Invoke-RestMethod -Uri "$BaseUrl/questions/$ExamType" -Method GET -TimeoutSec 10
    Write-Host "   Success: Retrieved $($questions.Count) questions" -ForegroundColor Green
    
    if ($questions.Count -gt 0) {
        Write-Host "   Sample question: $($questions[0].question.Substring(0, 50))..." -ForegroundColor Gray
    }
} catch {
    Write-Host "   Failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 3: Random Questions
Write-Host "`n3. Testing Random Questions Endpoint..." -ForegroundColor Yellow
try {
    $randomQuestions = Invoke-RestMethod -Uri "$BaseUrl/questions/$ExamType/random/3" -Method GET -TimeoutSec 10
    Write-Host "   Success: Retrieved $($randomQuestions.Count) random questions" -ForegroundColor Green
} catch {
    Write-Host "   Failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 4: Start Exam Session
Write-Host "`n4. Testing Exam Session..." -ForegroundColor Yellow
try {
    $sessionBody = @{
        examType = $ExamType
        userId = "test-user-$(Get-Date -Format 'HHmmss')"
        questionCount = 3
    } | ConvertTo-Json
    
    $session = Invoke-RestMethod -Uri "$BaseUrl/exam/start" -Method POST -Body $sessionBody -ContentType "application/json" -TimeoutSec 10
    Write-Host "   Success: Started exam session $($session.sessionId)" -ForegroundColor Green
    
    # Test 5: Submit Answer
    if ($session.sessionId) {
        Write-Host "`n5. Testing Submit Answer..." -ForegroundColor Yellow
        try {
            $answerBody = @{
                sessionId = $session.sessionId
                userId = $session.userId
                questionIndex = 0
                selectedAnswer = 1
            } | ConvertTo-Json
            
            Invoke-RestMethod -Uri "$BaseUrl/exam/answer" -Method POST -Body $answerBody -ContentType "application/json" -TimeoutSec 10
            Write-Host "   Success: Answer submitted" -ForegroundColor Green
            
            # Test 6: Complete Exam
            Write-Host "`n6. Testing Complete Exam..." -ForegroundColor Yellow
            try {
                $completeBody = @{
                    sessionId = $session.sessionId
                    userId = $session.userId
                } | ConvertTo-Json
                
                $result = Invoke-RestMethod -Uri "$BaseUrl/exam/complete" -Method POST -Body $completeBody -ContentType "application/json" -TimeoutSec 10
                Write-Host "   Success: Exam completed with score $($result.score)%" -ForegroundColor Green
            } catch {
                Write-Host "   Failed: $($_.Exception.Message)" -ForegroundColor Red
            }
        } catch {
            Write-Host "   Failed: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
} catch {
    Write-Host "   Failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`nAPI Test Complete!" -ForegroundColor Cyan