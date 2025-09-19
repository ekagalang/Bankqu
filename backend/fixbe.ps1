# Setup Laravel Backend for Windows
# Memperbaiki masalah database dan API routes

param(
    [switch]$MySQL = $false,  # Use MySQL instead of SQLite
    [switch]$Verbose = $false
)

Write-Host "🔧 Setting up Laravel Backend..." -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Blue

# Check if we're in backend directory
if (!(Test-Path "artisan")) {
    if (Test-Path "backend") {
        Set-Location "backend"
    } else {
        Write-Host "❌ Error: Not in Laravel backend directory!" -ForegroundColor Red
        exit 1
    }
}

Write-Host "📁 Current location: $(Get-Location)" -ForegroundColor Blue

# 1. Check and create .env file
Write-Host "📝 Setting up environment file..." -ForegroundColor Yellow

if (!(Test-Path ".env")) {
    if (Test-Path ".env.example") {
        Copy-Item ".env.example" ".env"
        Write-Host "✅ Created .env from .env.example" -ForegroundColor Green
    } else {
        Write-Host "❌ .env.example not found!" -ForegroundColor Red
        exit 1
    }
}

# 2. Generate application key
Write-Host "🔑 Generating application key..." -ForegroundColor Yellow
php artisan key:generate
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to generate application key!" -ForegroundColor Red
    exit 1
}

# 3. Setup database configuration
Write-Host "🗄️ Setting up database..." -ForegroundColor Yellow

if ($MySQL) {
    Write-Host "⚙️ Configuring MySQL database..." -ForegroundColor Blue
    
    $envContent = @"
APP_NAME=BankQu
APP_ENV=local
APP_DEBUG=true
APP_URL=http://localhost:8000

LOG_CHANNEL=stack
LOG_LEVEL=debug

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=Bankqu
DB_USERNAME=root
DB_PASSWORD=admin

SESSION_DRIVER=database
SESSION_LIFETIME=120

QUEUE_CONNECTION=database
CACHE_STORE=database

BROADCAST_CONNECTION=log
FILESYSTEM_DISK=local

MAIL_MAILER=log
"@
}

# Update .env file (preserve APP_KEY if exists)
$currentEnv = Get-Content ".env" -Raw -ErrorAction SilentlyContinue
if ($currentEnv -and $currentEnv -match "APP_KEY=(.+)") {
    $appKey = $matches[1]
    $envContent += "`nAPP_KEY=$appKey"
} else {
    $envContent += "`nAPP_KEY="
}

$envContent | Set-Content ".env" -Encoding UTF8

# Regenerate key to make sure it's valid
php artisan key:generate

# 4. Install dependencies
Write-Host "📦 Installing Composer dependencies..." -ForegroundColor Yellow
composer install --optimize-autoloader
if ($LASTEXITCODE -ne 0) {
    Write-Host "⚠️ Composer install had issues, but continuing..." -ForegroundColor Yellow
}

# 5. Clear caches
Write-Host "🧹 Clearing Laravel caches..." -ForegroundColor Yellow
php artisan config:clear
php artisan cache:clear
php artisan route:clear
php artisan view:clear

# 6. Run migrations
Write-Host "🗄️ Running database migrations..." -ForegroundColor Yellow

# First, create migration tables if they don't exist
php artisan migrate:install 2>$null

# Run migrations
$migrationResult = php artisan migrate --force 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "⚠️ Migration failed, creating essential tables..." -ForegroundColor Yellow
    
    # Create session table migration
    php artisan session:table
    php artisan queue:table
    
    # Try migration again
    php artisan migrate --force
}

Write-Host "✅ Database setup completed" -ForegroundColor Green

# 7. Create API routes
Write-Host "🛣️ Setting up API routes..." -ForegroundColor Yellow

$apiRoutes = @'
<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
*/

// Test route
Route::get('/', function () {
    return response()->json([
        'message' => 'BankQu API is running!',
        'version' => '1.0.0',
        'status' => 'active',
        'timestamp' => now()
    ]);
});

// Health check
Route::get('/health', function () {
    try {
        DB::connection()->getPdo();
        $dbStatus = 'connected';
    } catch (Exception $e) {
        $dbStatus = 'error: ' . $e->getMessage();
    }
    
    return response()->json([
        'status' => 'healthy',
        'timestamp' => now(),
        'database' => $dbStatus,
        'php_version' => PHP_VERSION,
        'laravel_version' => app()->version()
    ]);
});

// Auth routes (placeholder)
Route::prefix('auth')->group(function () {
    Route::post('/login', function (Request $request) {
        return response()->json([
            'message' => 'Login endpoint - to be implemented',
            'received_data' => $request->only(['email'])
        ]);
    });
    
    Route::post('/register', function (Request $request) {
        return response()->json([
            'message' => 'Register endpoint - to be implemented',
            'received_data' => $request->only(['name', 'email'])
        ]);
    });
    
    Route::post('/logout', function (Request $request) {
        return response()->json(['message' => 'Logout successful']);
    });
});

// Data endpoints (placeholder)
Route::prefix('v1')->group(function () {
    Route::get('/accounts', function () {
        return response()->json([
            'success' => true,
            'data' => [
                ['id' => 1, 'name' => 'BCA', 'type' => 'bank', 'balance' => 15000000],
                ['id' => 2, 'name' => 'Mandiri', 'type' => 'bank', 'balance' => 5000000],
                ['id' => 3, 'name' => 'Cash', 'type' => 'cash', 'balance' => 500000],
            ]
        ]);
    });
    
    Route::get('/transactions', function () {
        return response()->json([
            'success' => true,
            'data' => [
                'data' => [
                    ['id' => 1, 'type' => 'income', 'amount' => 8000000, 'description' => 'Salary'],
                    ['id' => 2, 'type' => 'expense', 'amount' => 150000, 'description' => 'Food'],
                ]
            ]
        ]);
    });
    
    Route::get('/investments', function () {
        return response()->json([
            'success' => true,
            'data' => [
                'investments' => [
                    ['id' => 1, 'name' => 'BBRI', 'type' => 'stock', 'value' => 480000],
                    ['id' => 2, 'name' => 'BBCA', 'type' => 'stock', 'value' => 410000],
                ]
            ]
        ]);
    });
    
    Route::get('/budgets', function () {
        return response()->json([
            'success' => true,
            'data' => [
                ['id' => 1, 'category' => 'Food', 'budgeted' => 2000000, 'spent' => 850000],
                ['id' => 2, 'category' => 'Transport', 'budgeted' => 800000, 'spent' => 320000],
            ]
        ]);
    });
});
'@

$apiRoutes | Set-Content "routes\api.php" -Encoding UTF8
Write-Host "✅ Created API routes" -ForegroundColor Green

# 8. Create web routes
Write-Host "🌐 Setting up web routes..." -ForegroundColor Yellow

$webRoutes = @'
<?php

use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
*/

Route::get('/', function () {
    return response()->json([
        'message' => 'BankQu Backend API',
        'api_endpoint' => url('/api'),
        'health_check' => url('/api/health'),
        'status' => 'running',
        'documentation' => 'Coming soon...'
    ]);
});
'@

$webRoutes | Set-Content "routes\web.php" -Encoding UTF8
Write-Host "✅ Created web routes" -ForegroundColor Green

# 9. Test database connection
Write-Host "🧪 Testing database connection..." -ForegroundColor Blue

$testResult = php artisan tinker --execute="try { DB::connection()->getPdo(); echo 'SUCCESS'; } catch(Exception \$e) { echo 'ERROR: ' . \$e->getMessage(); }" 2>&1

if ($testResult -like "*SUCCESS*") {
    Write-Host "✅ Database connection successful!" -ForegroundColor Green
} else {
    Write-Host "⚠️ Database connection issue: $testResult" -ForegroundColor Yellow
}

# 10. Final check
Write-Host ""
Write-Host "🔍 Final system check..." -ForegroundColor Blue

$checks = @(
    @{name=".env file"; path=".env"},
    @{name="SQLite database"; path="database\database.sqlite"},
    @{name="API routes"; path="routes\api.php"},
    @{name="Web routes"; path="routes\web.php"}
)

foreach ($check in $checks) {
    if (Test-Path $check.path) {
        Write-Host "✅ $($check.name)" -ForegroundColor Green
    } else {
        Write-Host "❌ $($check.name)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "🎉 Backend setup completed!" -ForegroundColor Green
Write-Host "============================" -ForegroundColor Blue
Write-Host "📍 Backend URL: http://127.0.0.1:8000" -ForegroundColor Blue
Write-Host "📍 API URL: http://127.0.0.1:8000/api" -ForegroundColor Blue
Write-Host "📍 Health check: http://127.0.0.1:8000/api/health" -ForegroundColor Blue

if ($MySQL) {
    Write-Host ""
    Write-Host "⚠️ MySQL Configuration:" -ForegroundColor Yellow
    Write-Host "   Make sure MySQL is running and create database 'bankqu'" -ForegroundColor Gray
    Write-Host "   Update DB_PASSWORD in .env if needed" -ForegroundColor Gray
}

Write-Host ""
$startServer = Read-Host "Start development server now? (y/n)"
if ($startServer -eq "y" -or $startServer -eq "Y") {
    Write-Host "🚀 Starting Laravel development server..." -ForegroundColor Green
    Write-Host "Press Ctrl+C to stop the server" -ForegroundColor Yellow
    php artisan serve --host=127.0.0.1 --port=8000
}