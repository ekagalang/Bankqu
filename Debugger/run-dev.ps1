# run-dev.ps1 - Script untuk menjalankan Backend Laravel + Frontend React
Write-Host "🚀 Starting BankQu Development Environment..." -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Blue

# Fungsi untuk membersihkan proses yang masih berjalan
function Stop-DevServers {
    Write-Host "🛑 Stopping development servers..." -ForegroundColor Yellow
    
    # Stop Laravel server (port 8000)
    Get-Process | Where-Object {$_.ProcessName -eq "php" -and $_.CommandLine -like "*artisan serve*"} | Stop-Process -Force -ErrorAction SilentlyContinue
    
    # Stop React server (port 3000)  
    Get-Process | Where-Object {$_.ProcessName -eq "node" -and $_.CommandLine -like "*react-scripts*"} | Stop-Process -Force -ErrorAction SilentlyContinue
    
    Write-Host "✅ Servers stopped" -ForegroundColor Green
}

# Fungsi untuk mengecek apakah port sedang digunakan
function Test-Port {
    param([int]$Port)
    try {
        $connection = New-Object System.Net.Sockets.TcpClient
        $connection.Connect("127.0.0.1", $Port)
        $connection.Close()
        return $true
    }
    catch {
        return $false
    }
}

# Cleanup sebelum start
Stop-DevServers

Write-Host ""
Write-Host "📋 Pre-flight checks..." -ForegroundColor Yellow

# Check if backend folder exists
if (-not (Test-Path "backend")) {
    Write-Host "❌ Backend folder not found!" -ForegroundColor Red
    exit 1
}

# Check if frontend folder exists
if (-not (Test-Path "frontend")) {
    Write-Host "❌ Frontend folder not found!" -ForegroundColor Red
    exit 1
}

# Check if ports are available
if (Test-Port 8000) {
    Write-Host "⚠️ Port 8000 is busy. Attempting to free it..." -ForegroundColor Yellow
    Stop-DevServers
    Start-Sleep 2
}

if (Test-Port 3000) {
    Write-Host "⚠️ Port 3000 is busy. Attempting to free it..." -ForegroundColor Yellow
    Stop-DevServers
    Start-Sleep 2
}

Write-Host "✅ Ports 8000 and 3000 are available" -ForegroundColor Green

# Setup Backend
Write-Host ""
Write-Host "🏗️ Setting up Backend (Laravel)..." -ForegroundColor Blue
cd backend

# Check .env file
if (-not (Test-Path ".env")) {
    Write-Host "📝 Creating .env file..." -ForegroundColor Yellow
    Copy-Item ".env.example" ".env"
    php artisan key:generate
}

# Install dependencies if needed
if (-not (Test-Path "vendor")) {
    Write-Host "📦 Installing PHP dependencies..." -ForegroundColor Yellow
    composer install
}

# Run migrations if needed
Write-Host "🗄️ Setting up database..." -ForegroundColor Yellow
php artisan migrate --force 2>$null

# Run seeders
Write-Host "🌱 Running seeders..." -ForegroundColor Yellow
php artisan db:seed --force 2>$null

Write-Host "✅ Backend setup complete" -ForegroundColor Green

# Setup Frontend
Write-Host ""
Write-Host "🎨 Setting up Frontend (React)..." -ForegroundColor Blue
cd ../frontend

# Install dependencies if needed
if (-not (Test-Path "node_modules")) {
    Write-Host "📦 Installing Node dependencies..." -ForegroundColor Yellow
    npm install
}

Write-Host "✅ Frontend setup complete" -ForegroundColor Green

# Start servers
Write-Host ""
Write-Host "🚀 Starting Development Servers..." -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Blue

# Start Backend in background
Write-Host "📡 Starting Laravel Backend (Port 8000)..." -ForegroundColor Yellow
cd ../backend
$backendJob = Start-Job -ScriptBlock {
    Set-Location $args[0]
    php artisan serve --host=127.0.0.1 --port=8000
} -ArgumentList (Get-Location)

# Wait a bit for backend to start
Start-Sleep 3

# Test backend health
try {
    $response = Invoke-RestMethod -Uri "http://127.0.0.1:8000/api/health" -TimeoutSec 5
    Write-Host "✅ Backend is running: $($response.status)" -ForegroundColor Green
} catch {
    Write-Host "⚠️ Backend might be starting up..." -ForegroundColor Yellow
}

# Start Frontend
Write-Host "🎨 Starting React Frontend (Port 3000)..." -ForegroundColor Yellow
cd ../frontend

# Set environment variable to not open browser automatically
$env:BROWSER = "none"

Write-Host ""
Write-Host "🎉 Development Environment Ready!" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Blue
Write-Host "📍 Backend:  http://127.0.0.1:8000" -ForegroundColor Cyan
Write-Host "📍 Frontend: http://127.0.0.1:3000" -ForegroundColor Cyan
Write-Host "📍 API:      http://127.0.0.1:8000/api" -ForegroundColor Cyan
Write-Host "📍 Health:   http://127.0.0.1:8000/api/health" -ForegroundColor Cyan
Write-Host ""
Write-Host "🔑 Login Credentials:" -ForegroundColor Yellow
Write-Host "   Email: admin@bankqu.com" -ForegroundColor Gray
Write-Host "   Password: admin123" -ForegroundColor Gray
Write-Host ""
Write-Host "Press Ctrl+C to stop all servers" -ForegroundColor Red
Write-Host ""

# Cleanup function for when script ends
$cleanup = {
    Write-Host ""
    Write-Host "🧹 Cleaning up..." -ForegroundColor Yellow
    
    # Stop background job
    if ($backendJob) {
        Stop-Job $backendJob -ErrorAction SilentlyContinue
        Remove-Job $backendJob -ErrorAction SilentlyContinue
    }
    
    # Stop any remaining processes
    Stop-DevServers
    
    Write-Host "✅ Cleanup complete" -ForegroundColor Green
}

# Register cleanup on script exit
Register-EngineEvent PowerShell.Exiting -Action $cleanup

# Start Frontend (this will block until Ctrl+C)
try {
    npm start
} finally {
    & $cleanup
}