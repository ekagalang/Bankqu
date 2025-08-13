# Manual Database Fix - Skip Tinker, Direct Approach
Write-Host "🔧 Manual Database Fix..." -ForegroundColor Cyan
Write-Host "=========================" -ForegroundColor Blue

function Check-Database-File {
    Write-Host "📄 Checking SQLite database file..." -ForegroundColor Yellow
    
    $dbPath = "backend/database/database.sqlite"
    if (Test-Path $dbPath) {
        $fileSize = (Get-Item $dbPath).Length
        Write-Host "✅ SQLite file exists: $fileSize bytes" -ForegroundColor Green
        
        if ($fileSize -gt 1000) {
            Write-Host "✅ Database has content (likely migrations ran)" -ForegroundColor Green
            return $true
        } else {
            Write-Host "⚠️ Database file is empty or very small" -ForegroundColor Yellow
            return $false
        }
    } else {
        Write-Host "❌ SQLite file not found" -ForegroundColor Red
        return $false
    }
}

function Force-Create-Database {
    Write-Host "🏗️ Force creating database and tables..." -ForegroundColor Yellow
    
    Push-Location "backend"
    
    # Ensure SQLite file exists
    $dbPath = "database/database.sqlite"
    if (!(Test-Path $dbPath)) {
        New-Item -ItemType File -Path $dbPath -Force | Out-Null
        Write-Host "✅ Created SQLite file" -ForegroundColor Green
    }
    
    # Clear all caches first
    Write-Host "   Clearing caches..." -ForegroundColor Gray
    php artisan config:clear
    php artisan cache:clear
    php artisan route:clear
    php artisan view:clear
    
    # Force fresh migration
    Write-Host "   Running fresh migrations..." -ForegroundColor Gray
    php artisan migrate:fresh --force
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Base migrations successful" -ForegroundColor Green
    }
    
    # Create sessions table specifically
    Write-Host "   Creating sessions table..." -ForegroundColor Gray
    php artisan make:session-table --force 2>$null
    php artisan migrate --force
    
    Pop-Location
}

function Create-Admin-User-Manual {
    Write-Host "👤 Creating admin user manually..." -ForegroundColor Yellow
    
    Push-Location "backend"
    
    # Create via PHP script instead of tinker
    $userCreationScript = @'
<?php
require_once 'vendor/autoload.php';

$app = require_once 'bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use App\Models\User;
use Illuminate\Support\Facades\Hash;

try {
    // Check if admin exists
    $admin = User::where('email', 'admin@bankqu.com')->first();
    
    if (!$admin) {
        $admin = User::create([
            'name' => 'Admin BankQu',
            'email' => 'admin@bankqu.com', 
            'password' => Hash::make('admin123'),
            'email_verified_at' => now(),
        ]);
        echo "SUCCESS: Admin user created\n";
    } else {
        echo "SUCCESS: Admin user already exists\n";
    }
    
    echo "Total users: " . User::count() . "\n";
} catch (Exception $e) {
    echo "ERROR: " . $e->getMessage() . "\n";
}
?>
'@
    
    $userCreationScript | Set-Content "create_admin.php" -Encoding UTF8
    $result = php create_admin.php
    Write-Host "   Result: $result" -ForegroundColor Gray
    
    # Clean up
    Remove-Item "create_admin.php" -ErrorAction SilentlyContinue
    
    Pop-Location
}

function Test-Login-Endpoint {
    Write-Host "🧪 Testing login endpoint..." -ForegroundColor Blue
    
    try {
        # Test with curl if available
        $testLogin = curl -s -X POST "http://localhost:8000/api/login" -H "Content-Type: application/json" -d '{\"email\":\"admin@bankqu.com\",\"password\":\"admin123\"}' 2>$null
        
        if ($testLogin -match "success" -or $testLogin -match "access_token") {
            Write-Host "✅ Login endpoint working!" -ForegroundColor Green
            return $true
        } elseif ($testLogin -match "error" -or $testLogin -match "credentials") {
            Write-Host "⚠️ Login endpoint reachable but credentials issue" -ForegroundColor Yellow
            Write-Host "   Response: $testLogin" -ForegroundColor Gray
            return $false
        } else {
            Write-Host "❌ Login endpoint not working properly" -ForegroundColor Red
            Write-Host "   Response: $testLogin" -ForegroundColor Gray
            return $false
        }
    } catch {
        Write-Host "⚠️ Cannot test with curl, check manually in browser" -ForegroundColor Yellow
        return $false
    }
}

function Check-Laravel-Log {
    Write-Host "📋 Checking Laravel logs for errors..." -ForegroundColor Yellow
    
    $logPath = "backend/storage/logs/laravel.log"
    if (Test-Path $logPath) {
        $logContent = Get-Content $logPath -Tail 20 -ErrorAction SilentlyContinue
        
        if ($logContent -match "ERROR" -or $logContent -match "SQLSTATE") {
            Write-Host "❌ Found errors in Laravel log:" -ForegroundColor Red
            $logContent | Select-String "ERROR|SQLSTATE|Exception" | Select-Object -Last 5 | ForEach-Object {
                Write-Host "   $_" -ForegroundColor Red
            }
        } else {
            Write-Host "✅ No obvious errors in recent logs" -ForegroundColor Green
        }
    } else {
        Write-Host "⚠️ No Laravel log file found" -ForegroundColor Yellow
    }
}

function Show-Manual-Steps {
    Write-Host ""
    Write-Host "🔧 Manual troubleshooting steps:" -ForegroundColor Yellow
    Write-Host "=================================" -ForegroundColor Blue
    Write-Host ""
    Write-Host "1. Test backend health:" -ForegroundColor Yellow
    Write-Host "   http://localhost:8000/api/health" -ForegroundColor Blue
    Write-Host ""
    Write-Host "2. Test login endpoint in browser/Postman:" -ForegroundColor Yellow
    Write-Host "   POST http://localhost:8000/api/login" -ForegroundColor Blue
    Write-Host "   Body: {\"email\":\"admin@bankqu.com\",\"password\":\"admin123\"}" -ForegroundColor Gray
    Write-Host ""
    Write-Host "3. Check backend terminal for error messages" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "4. Alternative: Use default Laravel seeder" -ForegroundColor Yellow
    Write-Host "   cd backend && php artisan db:seed --class=DatabaseSeeder" -ForegroundColor Gray
    Write-Host ""
    Write-Host "5. Reset everything:" -ForegroundColor Yellow
    Write-Host "   cd backend && rm database/database.sqlite" -ForegroundColor Gray
    Write-Host "   php artisan migrate:fresh --seed" -ForegroundColor Gray
}

# Main execution
Write-Host "🚀 Starting manual database fix..." -ForegroundColor Green
Write-Host ""

# 1. Check if database file exists and has content
$dbExists = Check-Database-File

if (!$dbExists) {
    # 2. Force create database if needed
    Force-Create-Database
}

# 3. Create admin user manually (skip tinker)
Create-Admin-User-Manual

# 4. Check Laravel logs for any errors
Check-Laravel-Log

# 5. Test login endpoint
Write-Host ""
$loginWorks = Test-Login-Endpoint

if ($loginWorks) {
    Write-Host ""
    Write-Host "🎉 Database and login should be working!" -ForegroundColor Green
    Write-Host "=======================================" -ForegroundColor Blue
    Write-Host "✅ Try logging in at http://localhost:3000" -ForegroundColor Green
    Write-Host "   Email: admin@bankqu.com" -ForegroundColor Gray
    Write-Host "   Password: admin123" -ForegroundColor Gray
} else {
    Write-Host ""
    Write-Host "❌ Still having issues..." -ForegroundColor Red
    Show-Manual-Steps
}

Write-Host ""
Write-Host "🔧 Manual fix completed!" -ForegroundColor Green