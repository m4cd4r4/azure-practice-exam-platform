# Frontend Quick Start Script for Azure Practice Exam Platform
# Fixes common React/npm issues and starts the development server

Write-Host "🚀 Azure Practice Exam - Frontend Quick Start" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan

$frontendPath = "..\src\frontend"

if (-not (Test-Path $frontendPath)) {
    Write-Host "❌ Frontend directory not found at: $frontendPath" -ForegroundColor Red
    Write-Host "💡 Run this script from the 'scripts' directory" -ForegroundColor Yellow
    exit 1
}

Set-Location $frontendPath

Write-Host "📂 Working in: $(Get-Location)" -ForegroundColor White
Write-Host ""

# Check for Node.js
Write-Host "🔍 Checking Node.js installation..." -ForegroundColor Yellow
try {
    $nodeVersion = node --version 2>$null
    if ($nodeVersion) {
        Write-Host "   ✅ Node.js: $nodeVersion" -ForegroundColor Green
    } else {
        throw "Node.js not found"
    }
} catch {
    Write-Host "   ❌ Node.js not installed" -ForegroundColor Red
    Write-Host "   💡 Install from: https://nodejs.org/" -ForegroundColor Yellow
    exit 1
}

# Check for npm
try {
    $npmVersion = npm --version 2>$null
    if ($npmVersion) {
        Write-Host "   ✅ npm: $npmVersion" -ForegroundColor Green
    } else {
        throw "npm not found"
    }
} catch {
    Write-Host "   ❌ npm not found" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Clean install if needed
if (Test-Path "node_modules") {
    Write-Host "🧹 Cleaning existing installation..." -ForegroundColor Yellow
    Remove-Item -Recurse -Force "node_modules" -ErrorAction SilentlyContinue
    Remove-Item -Force "package-lock.json" -ErrorAction SilentlyContinue
    Write-Host "   ✅ Cleaned node_modules and package-lock.json" -ForegroundColor Green
}

# Install dependencies
Write-Host "`n📦 Installing dependencies..." -ForegroundColor Yellow
try {
    npm install --legacy-peer-deps 2>&1 | Tee-Object -Variable npmOutput
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✅ Dependencies installed successfully" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️ npm install completed with warnings" -ForegroundColor Yellow
        Write-Host "   Attempting to fix vulnerabilities..." -ForegroundColor Gray
        npm audit fix --force 2>$null
    }
} catch {
    Write-Host "   ❌ Failed to install dependencies" -ForegroundColor Red
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Verify package.json
Write-Host "`n🔍 Verifying configuration..." -ForegroundColor Yellow
if (Test-Path "package.json") {
    try {
        $packageJson = Get-Content "package.json" | ConvertFrom-Json
        Write-Host "   ✅ Package: $($packageJson.name) v$($packageJson.version)" -ForegroundColor Green
        
        # Check for required scripts
        if ($packageJson.scripts.start) {
            Write-Host "   ✅ Start script found" -ForegroundColor Green
        } else {
            Write-Host "   ❌ Start script missing" -ForegroundColor Red
        }
    } catch {
        Write-Host "   ⚠️ Could not parse package.json" -ForegroundColor Yellow
    }
}

# Check environment files
Write-Host "`n🌍 Checking environment configuration..." -ForegroundColor Yellow
if (Test-Path ".env.development") {
    Write-Host "   ✅ Development environment file found" -ForegroundColor Green
} else {
    Write-Host "   ⚠️ Creating .env.development file..." -ForegroundColor Yellow
    @"
REACT_APP_API_BASE_URL=https://azpracticeexam-dev-functions.azurewebsites.net/api
REACT_APP_ENVIRONMENT=development
REACT_APP_DEBUG=true
"@ | Out-File -FilePath ".env.development" -Encoding UTF8
    Write-Host "   ✅ Environment file created" -ForegroundColor Green
}

# Start the development server
Write-Host "`n🚀 Starting React development server..." -ForegroundColor Yellow
Write-Host "   🌐 Will open http://localhost:3000" -ForegroundColor Cyan
Write-Host "   ⏹️ Press Ctrl+C to stop the server" -ForegroundColor Gray
Write-Host ""

# Start development server
try {
    # Set environment variable for better error messages
    $env:GENERATE_SOURCEMAP = "false"
    $env:BROWSER = "none"  # Don't auto-open browser yet
    
    Write-Host "Starting server..." -ForegroundColor White
    
    # Start the server and capture initial output
    $job = Start-Job -ScriptBlock {
        Set-Location $using:pwd
        npm start 2>&1
    }
    
    # Wait a bit for the server to start
    Start-Sleep -Seconds 5
    
    # Check if server started successfully
    $jobOutput = Receive-Job $job
    if ($jobOutput -match "webpack compiled|compiled successfully|Local:.*3000") {
        Write-Host "   ✅ Server started successfully!" -ForegroundColor Green
        Write-Host "   🌐 Opening http://localhost:3000..." -ForegroundColor Cyan
        
        # Open browser
        Start-Sleep -Seconds 2
        Start-Process "http://localhost:3000"
        
        Write-Host "`n📋 Server Status:" -ForegroundColor Cyan
        Write-Host "   Local:    http://localhost:3000" -ForegroundColor White
        Write-Host "   Network:  Available on your local network" -ForegroundColor White
        Write-Host ""
        Write-Host "🎯 What to do next:" -ForegroundColor Yellow
        Write-Host "   • Test the exam platform functionality" -ForegroundColor White
        Write-Host "   • Try starting an AZ-104 or AZ-900 practice exam" -ForegroundColor White
        Write-Host "   • Check browser console for any errors" -ForegroundColor White
        Write-Host ""
        Write-Host "⏹️ To stop the server: Press Ctrl+C in this window" -ForegroundColor Gray
        
        # Keep the server running
        Wait-Job $job
        
    } else {
        Write-Host "   ❌ Server failed to start" -ForegroundColor Red
        Write-Host "   Output: $jobOutput" -ForegroundColor Red
        
        # Try alternative start method
        Write-Host "`n🔄 Trying alternative start method..." -ForegroundColor Yellow
        npm start
    }
    
} catch {
    Write-Host "   ❌ Error starting server: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "`n💡 Manual start command:" -ForegroundColor Yellow
    Write-Host "   npm start" -ForegroundColor White
} finally {
    # Cleanup
    if ($job) {
        Remove-Job $job -Force -ErrorAction SilentlyContinue
    }
}