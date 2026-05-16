# Task Manager — one-time setup script
# Run from PowerShell as Administrator:
#   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
#   .\setup.ps1

$ErrorActionPreference = "Stop"
$projectDir = "E:\The manager core"
$branch = "claude/cross-platform-task-manager-g3wtA"
$repoUrl = "https://github.com/monegask/task-manager.git"

Write-Host ""
Write-Host "=== Task Manager Setup ===" -ForegroundColor Cyan
Write-Host ""

# 1. Check git
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "[ERROR] Git not found. Install from https://git-scm.com/download/win" -ForegroundColor Red
    exit 1
}

# 2. Check flutter
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Host "[ERROR] Flutter not found. Install from https://docs.flutter.dev/get-started/install/windows" -ForegroundColor Red
    exit 1
}

# 3. Clone or update repo
if (Test-Path $projectDir) {
    Write-Host "[INFO] Folder already exists, pulling latest changes..." -ForegroundColor Yellow
    Set-Location $projectDir
    git fetch origin
    git checkout $branch
    git pull origin $branch
} else {
    Write-Host "[INFO] Cloning repository to $projectDir..." -ForegroundColor Yellow
    git clone $repoUrl $projectDir
    Set-Location $projectDir
    git checkout $branch
}

Write-Host "[OK] Repository ready." -ForegroundColor Green

# 4. Create .env
$envPath = Join-Path $projectDir ".env"
if (Test-Path $envPath) {
    Write-Host "[INFO] .env already exists, skipping." -ForegroundColor Yellow
} else {
    Write-Host "[INFO] Creating .env..." -ForegroundColor Yellow
    @"
SUPABASE_URL=https://gzayaqafentdulrrbxin.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imd6YXlhcWFmZW50ZHVscnJieGluIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg1NTcwODYsImV4cCI6MjA5NDEzMzA4Nn0.3K9DEUytqyCBXH-AmBITN3mS1BuDKLXsQU8db5mnBBE
"@ | Out-File -FilePath $envPath -Encoding utf8 -NoNewline
    Write-Host "[OK] .env created." -ForegroundColor Green
}

# 5. Flutter dependencies
Write-Host "[INFO] Running flutter pub get..." -ForegroundColor Yellow
flutter pub get

Write-Host "[OK] Dependencies installed." -ForegroundColor Green

# 6. Code generation
Write-Host "[INFO] Running build_runner..." -ForegroundColor Yellow
dart run build_runner build --delete-conflicting-outputs

Write-Host "[OK] Code generation done." -ForegroundColor Green

# 7. Done
Write-Host ""
Write-Host "=== Setup complete! ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "To run on Windows:  flutter run -d windows" -ForegroundColor White
Write-Host "To run on Android:  flutter run -d android" -ForegroundColor White
Write-Host ""
Write-Host "Project folder: $projectDir" -ForegroundColor White
