# Initialize Git Repository and Commit to GitHub
# Run this script to set up version control for your Azure Practice Exam Platform

Write-Host "🚀 Initializing Git Repository for Azure Practice Exam Platform" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host ""

# Check if Git is installed
try {
    $gitVersion = git --version
    Write-Host "✅ Git installed: $gitVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Git not found. Please install Git first:" -ForegroundColor Red
    Write-Host "   Download from: https://git-scm.com/downloads" -ForegroundColor Yellow
    exit 1
}

# Initialize Git repository
Write-Host "📁 Initializing Git repository..." -ForegroundColor Yellow
git init

# Add all files
Write-Host "📄 Adding all files to Git..." -ForegroundColor Yellow
git add .

# Create initial commit
Write-Host "💾 Creating initial commit..." -ForegroundColor Yellow
git commit -m "Initial commit: Azure Practice Exam Platform with cost-optimized infrastructure

Features:
- Cost-optimized ARM templates (target: `$0-15/month)
- PowerShell deployment scripts
- Professional project structure
- GitHub Actions CI/CD pipeline
- Sample AZ-104 questions
- Comprehensive documentation

Ready for deployment and development!"

Write-Host "✅ Initial commit created successfully!" -ForegroundColor Green
Write-Host ""

# Instructions for GitHub
Write-Host "🔗 Next Steps - Create GitHub Repository:" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Go to GitHub.com and create a new repository:" -ForegroundColor Yellow
Write-Host "   Repository name: azure-practice-exam-platform" -ForegroundColor White
Write-Host "   Description: Cost-optimized Azure practice exam platform demonstrating enterprise architecture" -ForegroundColor White
Write-Host "   Visibility: Public (great for portfolio!)" -ForegroundColor White
Write-Host ""

Write-Host "2. After creating the repository, run these commands:" -ForegroundColor Yellow
Write-Host ""
Write-Host "   git remote add origin https://github.com/YOUR-USERNAME/azure-practice-exam-platform.git" -ForegroundColor White
Write-Host "   git branch -M main" -ForegroundColor White
Write-Host "   git push -u origin main" -ForegroundColor White
Write-Host ""

Write-Host "💡 Pro Tips:" -ForegroundColor Magenta
Write-Host "   • Use a descriptive README (already created!)" -ForegroundColor White
Write-Host "   • Add topics: azure, serverless, infrastructure-as-code, portfolio" -ForegroundColor White
Write-Host "   • Enable Issues and Projects for project management" -ForegroundColor White
Write-Host "   • Add a license (MIT already included)" -ForegroundColor White
Write-Host ""

Write-Host "🎯 Repository Benefits:" -ForegroundColor Green
Write-Host "   ✅ Professional project showcase" -ForegroundColor White
Write-Host "   ✅ Version control for safe development" -ForegroundColor White
Write-Host "   ✅ GitHub Actions for CI/CD" -ForegroundColor White
Write-Host "   ✅ Easy collaboration and sharing" -ForegroundColor White
Write-Host "   ✅ Portfolio piece for interviews" -ForegroundColor White
Write-Host ""

Write-Host "🔄 Git repository initialized and ready for GitHub!" -ForegroundColor Green
