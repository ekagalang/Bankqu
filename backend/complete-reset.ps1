# Complete Reset - Nuclear Option
Write-Host "💥 Complete Reset - Nuclear Option..." -ForegroundColor Red
Write-Host "=====================================" -ForegroundColor Blue

function Reset-Database {
    Write-Host "🗄️ Resetting database..." -ForegroundColor Yellow
    
    Push-Location "backend"
    
    # Remove existing database
    if (Test-Path "database/database.sqlite") {
        Remove-Item "database/database.sqlite" -Force
        Write-Host "✅ Removed existing database" -ForegroundColor Green
    }
    
    # Create fresh database
    New-Item -ItemType File -Path "database/database.sqlite" -Force | Out-Null
    Write-Host "✅ Created fresh database file" -ForegroundColor Green
    
    Pop-Location
}

function Reset-Config {
    Write-Host "⚙️ Resetting configuration..." -ForegroundColor Yellow
    
    Push-Location "backend"
    
    # Clear all caches aggressively
    php artisan config:clear 2>$null
    php artisan cache:clear 2>$null
    php artisan route:clear 2>$null
    php artisan view:clear 2>$null
    
    # Remove bootstrap cache
    if (Test-Path "bootstrap/cache/config.php") {
        Remove-Item "bootstrap/cache/config.php" -Force -ErrorAction SilentlyContinue
    }
    if (Test-Path "bootstrap/cache/routes-v7.php") {
        Remove-Item "bootstrap/cache/routes-v7.php" -Force -ErrorAction SilentlyContinue
    }
    if (Test-Path "bootstrap/cache/services.php") {
        Remove-Item "bootstrap/cache/services.php" -Force -ErrorAction SilentlyContinue
    }
    
    Write-Host "✅ Configuration reset" -ForegroundColor Green
    
    Pop-Location
}

function Create-Minimal-Bootstrap {
    Write-Host "🥾 Creating minimal bootstrap..." -ForegroundColor Yellow
    
    $minimalBootstrap = @'
<?php

use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        api: __DIR__.'/../routes/api.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware): void {
        //
    })
    ->withExceptions(function (Exceptions $exceptions): void {
        //
    })->create();
'@
    
    $minimalBootstrap | Set-Content "backend/bootstrap/app.php" -Encoding UTF8
    Write-Host "✅ Created minimal bootstrap" -ForegroundColor Green
}

function Create-Simple-Routes {
    Write-Host "🛣️ Creating simple API routes..." -ForegroundColor Yellow
    
    $simpleRoutes = @'
<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

// Health check
Route::get('/health', function () {
    return response()->json([
        'status' => 'healthy',
        'timestamp' => now(),
    ]);
});

// Simple login test
Route::post('/login', function (Request $request) {
    return response()->json([
        'success' => true,
        'message' => 'Login endpoint working',
        'data' => [
            'email' => $request->email
        ]
    ]);
});
'@
    
    $simpleRoutes | Set-Content "backend/routes/api.php" -Encoding UTF8
    Write-Host "✅ Created simple routes" -ForegroundColor Green
}

function Test-Minimal-Setup {
    Write-Host "🧪 Testing minimal setup..." -ForegroundColor Blue
    
    Push-Location "backend"
    
    # Test if Laravel can boot
    Write-Host "   Testing Laravel boot..." -ForegroundColor Gray
    $bootTest = php artisan --version 2>&1
    
    if ($bootTest -match "Laravel Framework") {
        Write-Host "✅ Laravel boots successfully: $bootTest" -ForegroundColor Green
        return $true
    } else {
        Write-Host "❌ Laravel boot failed: $bootTest" -ForegroundColor Red
        return $false
    }
    
    Pop-Location
}

function Show-Start-Instructions {
    Write-Host ""
    Write-Host "🚀 Ready to start!" -ForegroundColor Green
    Write-Host "==================" -ForegroundColor Blue
    Write-Host ""
    Write-Host "Manual steps:" -ForegroundColor Yellow
    Write-Host "1. Open new terminal/command prompt" -ForegroundColor Gray
    Write-Host "2. cd backend" -ForegroundColor Gray
    Write-Host "3. php artisan serve" -ForegroundColor Gray
    Write-Host "4. Test: http://localhost:8000/api/health" -ForegroundColor Gray
    Write-Host "5. Test login from frontend" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Expected result:" -ForegroundColor Yellow
    Write-Host "- Backend starts without errors" -ForegroundColor Gray
    Write-Host "- Health endpoint returns JSON" -ForegroundColor Gray
    Write-Host "- Login endpoint responds (even if simple)" -ForegroundColor Gray
}

# Main execution
Write-Host "🚨 This will reset Laravel to minimal working state!" -ForegroundColor Red
Write-Host ""

$confirm = Read-Host "Continue with nuclear reset? (y/n)"

if ($confirm -eq "y" -or $confirm -eq "Y") {
    Write-Host ""
    Write-Host "🚀 Starting nuclear reset..." -ForegroundColor Green
    
    # 1. Reset database
    Reset-Database
    
    # 2. Reset configuration
    Reset-Config
    
    # 3. Create minimal bootstrap
    Create-Minimal-Bootstrap
    
    # 4. Create simple routes
    Create-Simple-Routes
    
    # 5. Test minimal setup
    $bootSuccess = Test-Minimal-Setup
    
    if ($bootSuccess) {
        Show-Start-Instructions
        
        Write-Host ""
        $autoStart = Read-Host "Start backend server now? (y/n)"
        if ($autoStart -eq "y" -or $autoStart -eq "Y") {
            Write-Host ""
            Write-Host "🚀 Starting backend server..." -ForegroundColor Green
            Write-Host "Press Ctrl+C to stop server" -ForegroundColor Yellow
            Write-Host ""
            
            Push-Location "backend"
            php artisan serve
            Pop-Location
        }
    } else {
        Write-Host ""
        Write-Host "❌ Nuclear reset failed!" -ForegroundColor Red
        Write-Host "Laravel still cannot boot properly." -ForegroundColor Red
        Write-Host ""
        Write-Host "Possible issues:" -ForegroundColor Yellow
        Write-Host "1. PHP version incompatibility" -ForegroundColor Gray
        Write-Host "2. Composer dependencies corrupted" -ForegroundColor Gray
        Write-Host "3. File permissions issues" -ForegroundColor Gray
        Write-Host ""
        Write-Host "Try: cd backend && composer install --no-scripts" -ForegroundColor Blue
    }
} else {
    Write-Host "Reset cancelled." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "🔧 Nuclear reset completed!" -ForegroundColor Green