# Diagnostic Script untuk CORS Issue
Write-Host "🔍 Diagnosing CORS Issue..." -ForegroundColor Cyan
Write-Host "=============================" -ForegroundColor Blue

function Test-BackendURLs {
    Write-Host "🧪 Testing Backend URLs..." -ForegroundColor Yellow
    
    $urls = @(
        "http://localhost:8000",
        "http://localhost:8000/api",
        "http://localhost:8000/api/health",
        "http://127.0.0.1:8000",
        "http://127.0.0.1:8000/api",
        "http://127.0.0.1:8000/api/health"
    )
    
    foreach ($url in $urls) {
        try {
            $response = Invoke-RestMethod -Uri $url -TimeoutSec 5 -ErrorAction Stop
            Write-Host "✅ $url - OK" -ForegroundColor Green
        } catch {
            Write-Host "❌ $url - Failed: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

function Check-ContainerStatus {
    Write-Host ""
    Write-Host "🐳 Checking Container Status..." -ForegroundColor Yellow
    
    Write-Host "Current containers:" -ForegroundColor Gray
    docker-compose ps
    
    Write-Host ""
    Write-Host "Backend logs (last 10 lines):" -ForegroundColor Gray
    docker-compose logs --tail=10 backend
}

function Check-Backend-Config {
    Write-Host ""
    Write-Host "⚙️ Checking Backend Configuration..." -ForegroundColor Yellow
    
    # Check CORS config
    if (Test-Path "backend/config/cors.php") {
        $corsConfig = Get-Content "backend/config/cors.php" -Raw
        
        if ($corsConfig -match "localhost:3000") {
            Write-Host "✅ CORS config contains localhost:3000" -ForegroundColor Green
        } else {
            Write-Host "❌ CORS config missing localhost:3000" -ForegroundColor Red
            Write-Host "   Need to add localhost:3000 to allowed_origins" -ForegroundColor Yellow
        }
    }
    
    # Check .env
    if (Test-Path "backend/.env") {
        $envContent = Get-Content "backend/.env" -Raw
        
        if ($envContent -match "SANCTUM_STATEFUL_DOMAINS.*localhost:3000") {
            Write-Host "✅ SANCTUM_STATEFUL_DOMAINS includes localhost:3000" -ForegroundColor Green
        } else {
            Write-Host "❌ SANCTUM_STATEFUL_DOMAINS missing localhost:3000" -ForegroundColor Red
        }
    }
}

function Fix-CORS-Backend {
    Write-Host ""
    Write-Host "🔧 Applying CORS fixes..." -ForegroundColor Yellow
    
    # Update CORS config
    $corsConfig = @'
<?php

return [
    'paths' => ['api/*', 'sanctum/csrf-cookie'],
    'allowed_methods' => ['*'],
    'allowed_origins' => [
        'http://localhost:3000',
        'http://127.0.0.1:3000', 
        'http://localhost:3001',
        'http://127.0.0.1:3001'
    ],
    'allowed_origins_patterns' => [],
    'allowed_headers' => ['*'],
    'exposed_headers' => [],
    'max_age' => 0,
    'supports_credentials' => true,
];
'@
    
    $corsConfig | Set-Content "backend/config/cors.php" -Encoding UTF8
    Write-Host "✅ Updated CORS config" -ForegroundColor Green
    
    # Update backend .env
    $envPath = "backend/.env"
    if (Test-Path $envPath) {
        $envContent = Get-Content $envPath -Raw
        
        # Add or update SANCTUM_STATEFUL_DOMAINS
        if ($envContent -match "SANCTUM_STATEFUL_DOMAINS") {
            $envContent = $envContent -replace "SANCTUM_STATEFUL_DOMAINS=.*", "SANCTUM_STATEFUL_DOMAINS=localhost:3000,127.0.0.1:3000"
        } else {
            $envContent += "`nSANCTUM_STATEFUL_DOMAINS=localhost:3000,127.0.0.1:3000"
        }
        
        # Add SESSION_DOMAIN if not exists
        if ($envContent -notmatch "SESSION_DOMAIN") {
            $envContent += "`nSESSION_DOMAIN=null"
        }
        
        $envContent | Set-Content $envPath -Encoding UTF8
        Write-Host "✅ Updated backend .env" -ForegroundColor Green
    }
}

function Fix-CSS-Artifact {
    Write-Host ""
    Write-Host "🎨 Fixing CSS artifact (huruf 'n')..." -ForegroundColor Yellow
    
    # Check and fix index.css
    $indexCssPath = "frontend/src/index.css"
    if (Test-Path $indexCssPath) {
        $cssContent = Get-Content $indexCssPath -Raw
        
        # Remove any stray 'n' characters
        $cssContent = $cssContent -replace "^n\s*", ""
        $cssContent = $cssContent -replace "\s*n$", ""
        
        # Ensure clean Tailwind setup
        $cleanCSS = @'
@tailwind base;
@tailwind components;
@tailwind utilities;

body {
  margin: 0;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  background-color: #f8fafc;
}

code {
  font-family: source-code-pro, Menlo, Monaco, Consolas, 'Courier New', monospace;
}
'@
        
        $cleanCSS | Set-Content $indexCssPath -Encoding UTF8
        Write-Host "✅ Cleaned up index.css" -ForegroundColor Green
    }
}

function Restart-Services {
    Write-Host ""
    Write-Host "🔄 Restarting services..." -ForegroundColor Yellow
    
    # Clear Laravel caches
    docker-compose exec backend php artisan config:clear
    docker-compose exec backend php artisan cache:clear
    
    # Restart containers
    docker-compose restart
    
    Write-Host "✅ Services restarted" -ForegroundColor Green
    
    # Wait for services
    Write-Host "⏳ Waiting for services to be ready..." -ForegroundColor Gray
    Start-Sleep 10
}

function Final-Test {
    Write-Host ""
    Write-Host "🧪 Final Testing..." -ForegroundColor Blue
    
    # Test backend
    try {
        $backendTest = Invoke-RestMethod -Uri "http://localhost:8000/api/health" -TimeoutSec 10
        Write-Host "✅ Backend: $($backendTest.status)" -ForegroundColor Green
    } catch {
        Write-Host "❌ Backend: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    # Test CORS with curl if available
    try {
        $corsTest = curl -s -H "Origin: http://localhost:3000" -H "Access-Control-Request-Method: POST" -H "Access-Control-Request-Headers: Content-Type" -X OPTIONS "http://localhost:8000/api/login" 2>$null
        
        if ($corsTest -match "Access-Control-Allow-Origin") {
            Write-Host "✅ CORS: Preflight working" -ForegroundColor Green
        } else {
            Write-Host "⚠️ CORS: Preflight not detected" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "⚠️ CORS: Cannot test (curl not available)" -ForegroundColor Yellow
    }
}

function Show-Manual-Steps {
    Write-Host ""
    Write-Host "📋 Manual troubleshooting steps:" -ForegroundColor Yellow
    Write-Host "=================================" -ForegroundColor Blue
    Write-Host "1. Hard refresh browser: Ctrl+Shift+R" -ForegroundColor Gray
    Write-Host "2. Open DevTools > Network tab" -ForegroundColor Gray
    Write-Host "3. Try login and check failed request details" -ForegroundColor Gray
    Write-Host "4. Check if backend is on port 8000 or different port" -ForegroundColor Gray
    Write-Host ""
    Write-Host "🌐 URLs to verify:" -ForegroundColor Yellow
    Write-Host "   Frontend: http://localhost:3000" -ForegroundColor Blue
    Write-Host "   Backend:  http://localhost:8000/api/health" -ForegroundColor Blue
    Write-Host ""
    Write-Host "🔧 Alternative approach:" -ForegroundColor Yellow
    Write-Host "   Run backend locally: cd backend && php artisan serve" -ForegroundColor Gray
    Write-Host "   Keep frontend in Docker" -ForegroundColor Gray
}

# Main execution
Write-Host "🚀 Starting diagnosis..." -ForegroundColor Green
Write-Host ""

# 1. Test backend URLs
Test-BackendURLs

# 2. Check container status
Check-ContainerStatus

# 3. Check backend config
Check-Backend-Config

Write-Host ""
$applyFixes = Read-Host "Apply CORS fixes? (y/n)"

if ($applyFixes -eq "y" -or $applyFixes -eq "Y") {
    # 4. Fix CORS
    Fix-CORS-Backend
    
    # 5. Fix CSS artifact
    Fix-CSS-Artifact
    
    # 6. Restart services
    Restart-Services
    
    # 7. Final test
    Final-Test
    
    Write-Host ""
    Write-Host "🎉 Fixes applied!" -ForegroundColor Green
    Write-Host "Try login now at http://localhost:3000" -ForegroundColor Blue
}

Show-Manual-Steps

Write-Host ""
Write-Host "🔍 Diagnosis completed!" -ForegroundColor Green