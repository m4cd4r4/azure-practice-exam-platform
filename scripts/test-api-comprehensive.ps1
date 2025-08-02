# Comprehensive API Testing Script for Azure Practice Exam Platform
# Tests all endpoints and provides detailed diagnostics

param(
    [string]$BaseUrl = "https://azpracticeexam-dev-functions.azurewebsites.net/api",
    [switch]$Verbose,
    [string]$ExamType = "AZ-104"
)

# Test results tracking
$TestResults = @()
$OverallSuccess = $true

function Add-TestResult {
    param(
        [string]$TestName,
        [bool]$Success,
        [string]$Message,
        [object]$Data = $null,
        [int]$ResponseTime = 0
    )
    
    $TestResults += [PSCustomObject]@{
        Test = $TestName
        Success = $Success
        Message = $Message
        ResponseTime = $ResponseTime
        Data = $Data
        Timestamp = Get-Date
    }
    
    $status = if ($Success) { "✅" } else { "❌"; $script:OverallSuccess = $false }
    $timeInfo = if ($ResponseTime -gt 0) { " ($($ResponseTime)ms)" } else { "" }
    
    Write-Host "$status $TestName$timeInfo" -ForegroundColor $(if ($Success) { 'Green' } else { 'Red' })
    if ($Message) {
        Write-Host "   $Message" -ForegroundColor Gray
    }
    
    if ($Verbose -and $Data) {
        Write-Host "   Data: $($Data | ConvertTo-Json -Compress)" -ForegroundColor DarkGray
    }
}

function Test-Endpoint {
    param(
        [string]$Name,
        [string]$Url,
        [string]$Method = "GET",
        [object]$Body = $null,
        [hashtable]$Headers = @{}
    )
    
    try {
        $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
        
        $params = @{
            Uri = $Url
            Method = $Method
            Headers = $Headers
            TimeoutSec = 30
        }
        
        if ($Body) {
            $params.Body = ($Body | ConvertTo-Json -Depth 10)
            $params.ContentType = "application/json"
        }
        
        $response = Invoke-RestMethod @params
        $stopwatch.Stop()
        
        Add-TestResult -TestName $Name -Success $true -Message "Success" -Data $response -ResponseTime $stopwatch.ElapsedMilliseconds
        return $response
        
    } catch {
        $stopwatch.Stop()
        $errorMessage = $_.Exception.Message
        if ($_.Exception.Response) {
            $errorMessage += " (Status: $($_.Exception.Response.StatusCode))"
        }
        
        Add-TestResult -TestName $Name -Success $false -Message $errorMessage -ResponseTime $stopwatch.ElapsedMilliseconds
        return $null
    }
}

Write-Host "🧪 Azure Practice Exam Platform - API Test Suite" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan
Write-Host "Base URL: $BaseUrl" -ForegroundColor White
Write-Host "Exam Type: $ExamType" -ForegroundColor White
Write-Host ""

# Test 1: Health Check
Write-Host "🔍 Testing Core Endpoints..." -ForegroundColor Yellow
$healthResponse = Test-Endpoint -Name "Health Check" -Url "$BaseUrl/health"

# Test 2: Ping
Test-Endpoint -Name "Ping Endpoint" -Url "$BaseUrl/ping"

# Test 3: Get Questions
Write-Host "`n📚 Testing Question Endpoints..." -ForegroundColor Yellow
$questionsResponse = Test-Endpoint -Name "Get All Questions" -Url "$BaseUrl/questions/$ExamType"

# Test 4: Get Random Questions
$randomQuestionsResponse = Test-Endpoint -Name "Get Random Questions" -Url "$BaseUrl/questions/$ExamType/random/5"

# Test 5: Start Exam Session
Write-Host "`n🎯 Testing Exam Session Flow..." -ForegroundColor Yellow
$startExamBody = @{
    examType = $ExamType
    userId = "test-user-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    questionCount = 5
}

$examSessionResponse = Test-Endpoint -Name "Start Exam Session" -Url "$BaseUrl/exam/start" -Method "POST" -Body $startExamBody

# Test 6: Submit Answer (if exam session was created)
if ($examSessionResponse -and $examSessionResponse.sessionId) {
    $submitAnswerBody = @{
        sessionId = $examSessionResponse.sessionId
        userId = $startExamBody.userId
        questionIndex = 0
        selectedAnswer = 1
    }
    
    Test-Endpoint -Name "Submit Answer" -Url "$BaseUrl/exam/answer" -Method "POST" -Body $submitAnswerBody
    
    # Test 7: Complete Exam
    $completeExamBody = @{
        sessionId = $examSessionResponse.sessionId
        userId = $startExamBody.userId
    }
    
    $examResultResponse = Test-Endpoint -Name "Complete Exam" -Url "$BaseUrl/exam/complete" -Method "POST" -Body $completeExamBody
}

# Performance Analysis
Write-Host "`n📊 Performance Analysis..." -ForegroundColor Yellow
$successfulTests = $TestResults | Where-Object { $_.Success -and $_.ResponseTime -gt 0 }
if ($successfulTests) {
    $avgResponseTime = ($successfulTests | Measure-Object -Property ResponseTime -Average).Average
    $maxResponseTime = ($successfulTests | Measure-Object -Property ResponseTime -Maximum).Maximum
    $minResponseTime = ($successfulTests | Measure-Object -Property ResponseTime -Minimum).Minimum
    
    Write-Host "   Average Response Time: $([math]::Round($avgResponseTime))ms" -ForegroundColor White
    Write-Host "   Fastest Response: $($minResponseTime)ms" -ForegroundColor Green
    Write-Host "   Slowest Response: $($maxResponseTime)ms" -ForegroundColor $(if ($maxResponseTime -gt 5000) { 'Red' } else { 'Yellow' })
}

# Data Analysis
Write-Host "`n📈 Data Analysis..." -ForegroundColor Yellow
if ($questionsResponse) {
    Write-Host "   Total Questions Available: $($questionsResponse.Count)" -ForegroundColor White
    
    if ($questionsResponse.Count -gt 0) {
        $categories = $questionsResponse | Group-Object -Property category | Sort-Object Count -Descending
        Write-Host "   Question Categories:" -ForegroundColor White
        foreach ($category in $categories) {
            Write-Host "     - $($category.Name): $($category.Count) questions" -ForegroundColor Gray
        }
        
        $difficulties = $questionsResponse | Group-Object -Property difficulty | Sort-Object Count -Descending
        Write-Host "   Difficulty Distribution:" -ForegroundColor White
        foreach ($difficulty in $difficulties) {
            Write-Host "     - $($difficulty.Name): $($difficulty.Count) questions" -ForegroundColor Gray
        }
    }
}

# Connectivity Diagnostics
Write-Host "`n🔍 Connectivity Diagnostics..." -ForegroundColor Yellow
try {
    $dnsResult = Resolve-DnsName -Name "azpracticeexam-dev-functions.azurewebsites.net" -ErrorAction SilentlyContinue
    if ($dnsResult) {
        Write-Host "   ✅ DNS Resolution: Success" -ForegroundColor Green
        Write-Host "     IP Address: $($dnsResult[0].IPAddress)" -ForegroundColor Gray
    } else {
        Write-Host "   ❌ DNS Resolution: Failed" -ForegroundColor Red
    }
} catch {
    Write-Host "   ⚠️ DNS Resolution: Could not test" -ForegroundColor Yellow
}

# Test Summary
Write-Host "`n📋 Test Summary" -ForegroundColor Cyan
Write-Host "===============" -ForegroundColor Cyan

$successCount = ($TestResults | Where-Object { $_.Success }).Count
$totalCount = $TestResults.Count
$successRate = if ($totalCount -gt 0) { [math]::Round(($successCount / $totalCount) * 100, 1) } else { 0 }

Write-Host "Total Tests: $totalCount" -ForegroundColor White
Write-Host "Successful: $successCount" -ForegroundColor Green
Write-Host "Failed: $($totalCount - $successCount)" -ForegroundColor Red
Write-Host "Success Rate: $successRate%" -ForegroundColor $(if ($successRate -ge 80) { 'Green' } elseif ($successRate -ge 60) { 'Yellow' } else { 'Red' })

# Recommendations
Write-Host "`n💡 Recommendations" -ForegroundColor Cyan
Write-Host "==================" -ForegroundColor Cyan

if ($successRate -lt 100) {
    Write-Host "❌ Issues Found:" -ForegroundColor Red
    $failedTests = $TestResults | Where-Object { -not $_.Success }
    foreach ($test in $failedTests) {
        Write-Host "   • $($test.Test): $($test.Message)" -ForegroundColor Yellow
    }
    
    Write-Host "`n🔧 Suggested Actions:" -ForegroundColor Yellow
    Write-Host "   1. Check Azure Function App status in portal" -ForegroundColor White
    Write-Host "   2. Verify connection string configuration" -ForegroundColor White
    Write-Host "   3. Check Azure Tables for question data" -ForegroundColor White
    Write-Host "   4. Review Function App logs for errors" -ForegroundColor White
} else {
    Write-Host "🎉 All tests passed! Your API is working correctly." -ForegroundColor Green
}

# Performance Recommendations
if ($successfulTests) {
    $slowTests = $successfulTests | Where-Object { $_.ResponseTime -gt 2000 }
    if ($slowTests) {
        Write-Host "`n⚡ Performance Optimization:" -ForegroundColor Yellow
        foreach ($test in $slowTests) {
            Write-Host "   • $($test.Test) is slow ($($test.ResponseTime)ms)" -ForegroundColor Yellow
        }
        Write-Host "   Consider optimizing slow endpoints or increasing Function App resources" -ForegroundColor White
    }
}

# Export detailed results if requested
if ($Verbose) {
    Write-Host "`n📄 Detailed Results" -ForegroundColor Cyan
    Write-Host "===================" -ForegroundColor Cyan
    $TestResults | Format-Table -AutoSize -Property Test, Success, ResponseTime, Message
}

# Set exit code based on overall success
if ($OverallSuccess) {
    Write-Host "`n✅ All critical tests passed!" -ForegroundColor Green
    exit 0
} else {
    Write-Host "`n❌ Some tests failed. Check the recommendations above." -ForegroundColor Red
    exit 1
}