# Debug 500 Internal Server Error
Write-Host "🔍 Debugging 500 Internal Server Error..." -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Blue

function Test-API-Endpoints {
    Write-Host "🧪 Testing API endpoints..." -ForegroundColor Yellow
    
    $endpoints = @(
        "http://localhost:8000",
        "http://localhost:8000/api", 
        "http://localhost:8000/api/health"
    )
    
    foreach ($endpoint in $endpoints) {
        try {
            $response = Invoke-RestMethod -Uri $endpoint -TimeoutSec 5 -ErrorAction Stop
            Write-Host "✅ $endpoint - OK" -ForegroundColor Green
        } catch {
            $statusCode = $_.Exception.Response.StatusCode.value__
            Write-Host "❌ $endpoint - Error $statusCode" -ForegroundColor Red
            
            if ($statusCode -eq 500) {
                Write-Host "   500 Internal Server Error detected!" -ForegroundColor Red
            }
        }
    }
}

function Test-Login-Direct {
    Write-Host ""
    Write-Host "🔑 Testing login endpoint directly..." -ForegroundColor Yellow
    
    try {
        $loginData = @{
            email = "admin@bankqu.com"
            password = "admin123"
        } | ConvertTo-Json
        
        $response = Invoke-RestMethod -Uri "http://localhost:8000/api/login" -Method POST -Body $loginData -ContentType "application/json" -ErrorAction Stop
        
        Write-Host "✅ Login successful!" -ForegroundColor Green
        Write-Host "   Response: $($response | ConvertTo-Json -Compress)" -ForegroundColor Gray
        
    } catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
        Write-Host "❌ Login failed - Error $statusCode" -ForegroundColor Red
        
        try {
            $errorResponse = $_.ErrorDetails.Message | ConvertFrom-Json
            Write-Host "   Error details: $($errorResponse.message)" -ForegroundColor Red
        } catch {
            Write-Host "   Raw error: $($_.Exception.Message)" -ForegroundColor Red
        }
        
        return $false
    }
    
    return $true
}

function Check-Laravel-Routes {
    Write-Host ""
    Write-Host "🛣️ Checking Laravel routes..." -ForegroundColor Yellow
    
    Push-Location "backend"
    
    Write-Host "   Available API routes:" -ForegroundColor Gray
    $routes = php artisan route:list --path=api 2>$null
    
    if ($routes -match "login") {
        Write-Host "✅ Login route found" -ForegroundColor Green
    } else {
        Write-Host "❌ Login route NOT found" -ForegroundColor Red
        Write-Host "   Need to check routes/api.php" -ForegroundColor Yellow
    }
    
    Pop-Location
}

function Check-Database-Users {
    Write-Host ""
    Write-Host "👥 Checking database users..." -ForegroundColor Yellow
    
    Push-Location "backend"
    
    # Check if SQLite file has content
    $dbPath = "database/database.sqlite"
    if (Test-Path $dbPath) {
        $fileSize = (Get-Item $dbPath).Length
        Write-Host "   Database file size: $fileSize bytes" -ForegroundColor Gray
        
        if ($fileSize -lt 1000) {
            Write-Host "❌ Database file too small - likely empty" -ForegroundColor Red
            Write-Host "   Running migrations again..." -ForegroundColor Yellow
            
            php artisan migrate:fresh --force
            php artisan make:session-table --force
            php artisan migrate --force
        }
    }
    
    # Try to create user via direct SQL approach
    Write-Host "   Creating admin user via SQL..." -ForegroundColor Gray
    
    $sqlScript = @'
<?php
require_once 'vendor/autoload.php';
$app = require_once 'bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

try {
    // Insert user directly
    DB::table('users')->updateOrInsert(
        ['email' => 'admin@bankqu.com'],
        [
            'name' => 'Admin BankQu',
            'email' => 'admin@bankqu.com',
            'password' => Hash::make('admin123'),
            'email_verified_at' => now(),
            'created_at' => now(),
            'updated_at' => now(),
        ]
    );
    
    $userCount = DB::table('users')->count();
    echo "SUCCESS: User created. Total users: $userCount\n";
    
} catch (Exception $e) {
    echo "ERROR: " . $e->getMessage() . "\n";
}
?>
'@
    
    $sqlScript | Set-Content "insert_user.php" -Encoding UTF8
    $result = php insert_user.php 2>&1
    Write-Host "   Result: $result" -ForegroundColor Gray
    
    Remove-Item "insert_user.php" -ErrorAction SilentlyContinue
    
    Pop-Location
}

function Check-Auth-Controller {
    Write-Host ""
    Write-Host "🎮 Checking AuthController..." -ForegroundColor Yellow
    
    $authControllerPath = "backend/app/Http/Controllers/AuthController.php"
    if (Test-Path $authControllerPath) {
        Write-Host "✅ AuthController exists" -ForegroundColor Green
        
        $content = Get-Content $authControllerPath -Raw
        if ($content -match "function login") {
            Write-Host "✅ Login method found in AuthController" -ForegroundColor Green
        } else {
            Write-Host "❌ Login method NOT found in AuthController" -ForegroundColor Red
        }
    } else {
        Write-Host "❌ AuthController NOT found" -ForegroundColor Red
        Write-Host "   Creating basic AuthController..." -ForegroundColor Yellow
        
        Push-Location "backend"
        php artisan make:controller AuthController
        Pop-Location
    }
}

function Show-Debug-Commands {
    Write-Host ""
    Write-Host "🔧 Manual debugging commands:" -ForegroundColor Yellow
    Write-Host "=============================" -ForegroundColor Blue
    Write-Host ""
    Write-Host "1. Check backend terminal output when login fails" -ForegroundColor Yellow
    Write-Host "2. Test in browser:" -ForegroundColor Yellow
    Write-Host "   http://localhost:8000/api/login (should show 405 Method Not Allowed)" -ForegroundColor Blue
    Write-Host ""
    Write-Host "3. Check Laravel log:" -ForegroundColor Yellow
    Write-Host "   backend/storage/logs/laravel.log" -ForegroundColor Blue
    Write-Host ""
    Write-Host "4. Enable detailed errors in .env:" -ForegroundColor Yellow
    Write-Host "   APP_DEBUG=true" -ForegroundColor Gray
    Write-Host "   LOG_LEVEL=debug" -ForegroundColor Gray
    Write-Host ""
    Write-Host "5. Test with Postman/curl:" -ForegroundColor Yellow
    Write-Host "   POST http://localhost:8000/api/login" -ForegroundColor Blue
    Write-Host "   Content-Type: application/json" -ForegroundColor Gray
    Write-Host "   Body: {\"email\":\"admin@bankqu.com\",\"password\":\"admin123\"}" -ForegroundColor Gray
    Write-Host ""
    Write-Host "6. Reset everything:" -ForegroundColor Yellow
    Write-Host "   cd backend" -ForegroundColor Gray
    Write-Host "   rm database/database.sqlite" -ForegroundColor Gray
    Write-Host "   php artisan migrate:fresh" -ForegroundColor Gray
    Write-Host "   php artisan db:seed" -ForegroundColor Gray
}

function Check-Laravel-Log {
    Write-Host ""
    Write-Host "📋 Checking recent Laravel errors..." -ForegroundColor Yellow
    
    $logPath = "backend/storage/logs/laravel.log"
    if (Test-Path $logPath) {
        Write-Host "   Reading last 10 error entries..." -ForegroundColor Gray
        
        $logContent = Get-Content $logPath -Tail 50 -ErrorAction SilentlyContinue
        $errors = $logContent | Where-Object { $_ -match "ERROR|Exception|SQLSTATE" } | Select-Object -Last 10
        
        if ($errors) {
            Write-Host "❌ Recent errors found:" -ForegroundColor Red
            foreach ($error in $errors) {
                Write-Host "   $error" -ForegroundColor Red
            }
        } else {
            Write-Host "✅ No recent errors in log" -ForegroundColor Green
        }
    } else {
        Write-Host "⚠️ Laravel log file not found" -ForegroundColor Yellow
    }
}

# Main execution
Write-Host "🚀 Starting 500 error diagnosis..." -ForegroundColor Green
Write-Host ""

# 1. Test API endpoints
Test-API-Endpoints

# 2. Check Laravel log first
Check-Laravel-Log

# 3. Check Laravel routes
Check-Laravel-Routes

# 4. Check AuthController
Check-Auth-Controller

# 5. Check database and users
Check-Database-Users

# 6. Test login directly
$loginSuccess = Test-Login-Direct

if (!$loginSuccess) {
    Write-Host ""
    Write-Host "❌ Login still failing with 500 error" -ForegroundColor Red
    Write-Host "=====================================" -ForegroundColor Red
    
    Write-Host ""
    Write-Host "🔍 IMPORTANT: Check backend terminal output!" -ForegroundColor Yellow
    Write-Host "The terminal running 'php artisan serve' will show the exact error." -ForegroundColor Yellow
    
    Show-Debug-Commands
} else {
    Write-Host ""
    Write-Host "✅ Login working via direct API test!" -ForegroundColor Green
    Write-Host "Problem might be with frontend request format." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "🔍 Diagnosis completed!" -ForegroundColor Green