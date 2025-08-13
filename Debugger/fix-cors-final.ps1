# Ultimate CORS Fix - Solve Once and For All
Write-Host "🔧 Ultimate CORS Fix..." -ForegroundColor Cyan
Write-Host "========================" -ForegroundColor Blue

function Test-BackendAccess {
    Write-Host "🧪 Testing backend access..." -ForegroundColor Yellow
    
    $ports = @(8000, 8001, 8080, 80)
    $hostnames = @("localhost", "127.0.0.1")
    
    foreach ($hostname in $hostnames) {
        foreach ($port in $ports) {
            $url = "http://${hostname}:${port}/api/health"
            try {
                $response = Invoke-RestMethod -Uri $url -TimeoutSec 3 -ErrorAction Stop
                Write-Host "✅ Backend found: $url" -ForegroundColor Green
                return @{
                    "host" = $hostname
                    "port" = $port
                    "url" = "http://${hostname}:${port}"
                }
            } catch {
                Write-Host "❌ $url - Not accessible" -ForegroundColor Red
            }
        }
    }
    
    return $null
}

function Fix-CORS-Comprehensive {
    param($backendUrl)
    
    Write-Host "🌐 Applying comprehensive CORS fix..." -ForegroundColor Yellow
    
    # 1. Update Laravel CORS middleware
    $corsMiddleware = @'
<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class CorsMiddleware
{
    public function handle(Request $request, Closure $next)
    {
        // Handle preflight OPTIONS request
        if ($request->getMethod() === "OPTIONS") {
            return response('', 200)
                ->header('Access-Control-Allow-Origin', '*')
                ->header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS')
                ->header('Access-Control-Allow-Headers', 'Content-Type, Accept, Authorization, X-Requested-With, X-CSRF-TOKEN');
        }

        $response = $next($request);

        // Add CORS headers to all responses
        return $response
            ->header('Access-Control-Allow-Origin', '*')
            ->header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS')
            ->header('Access-Control-Allow-Headers', 'Content-Type, Accept, Authorization, X-Requested-With, X-CSRF-TOKEN')
            ->header('Access-Control-Allow-Credentials', 'true');
    }
}
'@
    
    # Create middleware directory if not exists
    if (!(Test-Path "backend/app/Http/Middleware")) {
        New-Item -ItemType Directory -Path "backend/app/Http/Middleware" -Force
    }
    
    $corsMiddleware | Set-Content "backend/app/Http/Middleware/CorsMiddleware.php" -Encoding UTF8
    Write-Host "✅ Created CORS middleware" -ForegroundColor Green
    
    # 2. Update CORS config
    $corsConfig = @'
<?php

return [
    'paths' => ['api/*', 'sanctum/csrf-cookie', '*'],
    'allowed_methods' => ['*'],
    'allowed_origins' => ['*'],
    'allowed_origins_patterns' => [],
    'allowed_headers' => ['*'],
    'exposed_headers' => [],
    'max_age' => 0,
    'supports_credentials' => false,
];
'@
    
    $corsConfig | Set-Content "backend/config/cors.php" -Encoding UTF8
    Write-Host "✅ Updated CORS config (permissive)" -ForegroundColor Green
    
    # 3. Update bootstrap/app.php to register middleware
    $appBootstrap = @'
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
        // Global CORS middleware
        $middleware->append(\App\Http\Middleware\CorsMiddleware::class);
        
        // API middleware
        $middleware->api(prepend: [
            \Laravel\Sanctum\Http\Middleware\EnsureFrontendRequestsAreStateful::class,
        ]);

        // CORS middleware for API
        $middleware->api(append: [
            \Illuminate\Http\Middleware\HandleCors::class,
        ]);

        $middleware->alias([
            'auth' => \App\Http\Middleware\Authenticate::class,
            'guest' => \App\Http\Middleware\RedirectIfAuthenticated::class,
            'cors' => \App\Http\Middleware\CorsMiddleware::class,
        ]);
    })
    ->withExceptions(function (Exceptions $exceptions): void {
        //
    })->create();
'@
    
    $appBootstrap | Set-Content "backend/bootstrap/app.php" -Encoding UTF8
    Write-Host "✅ Updated app bootstrap with CORS middleware" -ForegroundColor Green
    
    # 4. Update .env
    $envPath = "backend/.env"
    if (Test-Path $envPath) {
        $envContent = Get-Content $envPath -Raw
        
        # Remove existing SANCTUM settings and add new ones
        $envContent = $envContent -replace "SANCTUM_STATEFUL_DOMAINS=.*", ""
        $envContent = $envContent -replace "SESSION_DOMAIN=.*", ""
        
        $envContent += @"

# CORS Configuration
SANCTUM_STATEFUL_DOMAINS=localhost:3000,127.0.0.1:3000,localhost:3001,127.0.0.1:3001
SESSION_DOMAIN=null
CORS_ALLOWED_ORIGINS=*
"@
        
        $envContent | Set-Content $envPath -Encoding UTF8
        Write-Host "✅ Updated backend .env" -ForegroundColor Green
    }
    
    # 5. Update frontend to use detected backend URL
    if ($backendUrl) {
        $frontendApiUrl = "$($backendUrl)/api"
        
        # Update AuthContext.js
        $authContextPath = "frontend/src/contexts/AuthContext.js"
        if (Test-Path $authContextPath) {
            $content = Get-Content $authContextPath -Raw
            $content = $content -replace "const API_BASE_URL = 'http://.*?/api';", "const API_BASE_URL = '$frontendApiUrl';"
            $content | Set-Content $authContextPath -Encoding UTF8
            Write-Host "✅ Updated AuthContext.js to use $frontendApiUrl" -ForegroundColor Green
        }
        
        # Update services/api.js
        $apiServicePath = "frontend/src/services/api.js"
        if (Test-Path $apiServicePath) {
            $content = Get-Content $apiServicePath -Raw
            $content = $content -replace "const API_BASE_URL = 'http://.*?/api';", "const API_BASE_URL = '$frontendApiUrl';"
            $content | Set-Content $apiServicePath -Encoding UTF8
            Write-Host "✅ Updated api.js to use $frontendApiUrl" -ForegroundColor Green
        }
        
        # Update frontend .env
        $frontendEnv = @"
REACT_APP_API_URL=$frontendApiUrl
REACT_APP_APP_NAME=BankQu
CHOKIDAR_USEPOLLING=true
GENERATE_SOURCEMAP=false
BROWSER=none
"@
        $frontendEnv | Set-Content "frontend/.env" -Encoding UTF8
        Write-Host "✅ Updated frontend .env" -ForegroundColor Green
    }
}

function Alternative-Setup {
    Write-Host ""
    Write-Host "🔄 Alternative: Run Backend Locally..." -ForegroundColor Yellow
    
    $runLocal = Read-Host "Backend Docker seems problematic. Run backend locally instead? (y/n)"
    
    if ($runLocal -eq "y" -or $runLocal -eq "Y") {
        Write-Host "Setting up local backend..." -ForegroundColor Blue
        
        # Stop backend container
        docker-compose stop backend
        
        # Update frontend to point to local backend
        $localBackendUrl = "http://localhost:8000/api"
        
        # Update AuthContext.js
        $authContextPath = "frontend/src/contexts/AuthContext.js"
        if (Test-Path $authContextPath) {
            $content = Get-Content $authContextPath -Raw
            $content = $content -replace "const API_BASE_URL = 'http://.*?/api';", "const API_BASE_URL = '$localBackendUrl';"
            $content | Set-Content $authContextPath -Encoding UTF8
            Write-Host "✅ Updated AuthContext.js for local backend" -ForegroundColor Green
        }
        
        Write-Host ""
        Write-Host "🚀 Start backend manually:" -ForegroundColor Green
        Write-Host "   cd backend" -ForegroundColor Gray
        Write-Host "   php artisan serve" -ForegroundColor Gray
        Write-Host ""
        Write-Host "Frontend will remain in Docker on port 3000" -ForegroundColor Blue
        
        return $true
    }
    
    return $false
}

function Restart-And-Test {
    Write-Host ""
    Write-Host "🔄 Restarting services..." -ForegroundColor Yellow
    
    # Clear Laravel caches
    docker-compose exec backend php artisan config:clear 2>$null
    docker-compose exec backend php artisan cache:clear 2>$null
    docker-compose exec backend php artisan route:clear 2>$null
    
    # Restart backend
    docker-compose restart backend
    
    Write-Host "⏳ Waiting for backend to restart..." -ForegroundColor Gray
    Start-Sleep 10
    
    # Test again
    $backendInfo = Test-BackendAccess
    
    if ($backendInfo) {
        Write-Host "✅ Backend accessible at $($backendInfo.url)" -ForegroundColor Green
        
        # Test CORS
        Write-Host "🧪 Testing CORS..." -ForegroundColor Blue
        try {
            $testUrl = "$($backendInfo.url)/api/health"
            $response = Invoke-WebRequest -Uri $testUrl -Method OPTIONS -Headers @{
                "Origin" = "http://localhost:3000"
                "Access-Control-Request-Method" = "POST"
                "Access-Control-Request-Headers" = "Content-Type"
            } -UseBasicParsing -TimeoutSec 5
            
            if ($response.Headers["Access-Control-Allow-Origin"]) {
                Write-Host "✅ CORS preflight working" -ForegroundColor Green
            } else {
                Write-Host "⚠️ CORS headers not found in response" -ForegroundColor Yellow
            }
        } catch {
            Write-Host "⚠️ CORS test failed: $($_.Exception.Message)" -ForegroundColor Yellow
        }
        
        return $true
    } else {
        Write-Host "❌ Backend still not accessible" -ForegroundColor Red
        return $false
    }
}

# Main execution
Write-Host "🚀 Starting ultimate CORS fix..." -ForegroundColor Green
Write-Host ""

# 1. Test current backend access
$backendInfo = Test-BackendAccess

if ($backendInfo) {
    Write-Host "✅ Backend detected at $($backendInfo.url)" -ForegroundColor Green
    
    # 2. Apply comprehensive CORS fix
    Fix-CORS-Comprehensive -backendUrl $backendInfo.url
    
    # 3. Restart and test
    $success = Restart-And-Test
    
    if ($success) {
        Write-Host ""
        Write-Host "🎉 CORS fix completed!" -ForegroundColor Green
        Write-Host "======================" -ForegroundColor Blue
        Write-Host "✅ Backend: $($backendInfo.url)" -ForegroundColor Green
        Write-Host "✅ Frontend: http://localhost:3000" -ForegroundColor Green
        Write-Host ""
        Write-Host "Try logging in now!" -ForegroundColor Yellow
    } else {
        Alternative-Setup
    }
} else {
    Write-Host "❌ Backend not accessible on common ports" -ForegroundColor Red
    Alternative-Setup
}

Write-Host ""
Write-Host "📋 Next steps if still not working:" -ForegroundColor Yellow
Write-Host "1. Hard refresh browser (Ctrl+Shift+R)" -ForegroundColor Gray
Write-Host "2. Check browser console for specific errors" -ForegroundColor Gray
Write-Host "3. Try incognito mode" -ForegroundColor Gray
Write-Host "4. Consider running backend locally" -ForegroundColor Gray

Write-Host ""
Write-Host "🔧 Ultimate CORS fix completed!" -ForegroundColor Green