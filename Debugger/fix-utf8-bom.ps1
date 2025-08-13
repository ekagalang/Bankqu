# Fix UTF-8 BOM Characters in API Response
Write-Host "🔧 Fixing UTF-8 BOM Characters..." -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Blue

function Fix-UTF8-Encoding {
    Write-Host "📝 Creating clean API routes without BOM..." -ForegroundColor Yellow
    
    # Create routes without BOM by using UTF8NoBOM encoding
    $cleanRoutes = @'
<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::middleware(['api'])->group(function () {
    
    Route::get('/health', function () {
        return response()->json([
            'status' => 'healthy',
            'timestamp' => now(),
        ])->header('Access-Control-Allow-Origin', '*')
          ->header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
          ->header('Access-Control-Allow-Headers', 'Content-Type, Accept, Authorization');
    });
    
    Route::post('/login', function (Request $request) {
        if (!$request->email || !$request->password) {
            return response()->json([
                'success' => false,
                'message' => 'Email and password are required'
            ], 422)->header('Access-Control-Allow-Origin', '*')
                   ->header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
                   ->header('Access-Control-Allow-Headers', 'Content-Type, Accept, Authorization');
        }
        
        return response()->json([
            'success' => true,
            'message' => 'Login successful',
            'data' => [
                'user' => [
                    'id' => 1,
                    'name' => 'Admin BankQu',
                    'email' => $request->email,
                    'email_verified_at' => now()
                ],
                'access_token' => 'demo-token-' . time() . '-' . rand(1000, 9999),
                'token_type' => 'Bearer'
            ]
        ])->header('Access-Control-Allow-Origin', '*')
          ->header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
          ->header('Access-Control-Allow-Headers', 'Content-Type, Accept, Authorization');
    });
    
    Route::post('/register', function (Request $request) {
        return response()->json([
            'success' => true,
            'message' => 'Registration successful',
            'data' => [
                'user' => [
                    'id' => 2,
                    'name' => $request->name,
                    'email' => $request->email,
                    'email_verified_at' => now()
                ],
                'access_token' => 'demo-token-' . time() . '-' . rand(1000, 9999),
                'token_type' => 'Bearer'
            ]
        ])->header('Access-Control-Allow-Origin', '*');
    });
    
    Route::post('/logout', function (Request $request) {
        return response()->json([
            'success' => true,
            'message' => 'Logged out successfully'
        ])->header('Access-Control-Allow-Origin', '*');
    });
    
    Route::get('/me', function (Request $request) {
        return response()->json([
            'success' => true,
            'data' => [
                'id' => 1,
                'name' => 'Admin BankQu',
                'email' => 'admin@bankqu.com'
            ]
        ])->header('Access-Control-Allow-Origin', '*');
    });
    
    Route::options('/{any}', function () {
        return response('', 200)
            ->header('Access-Control-Allow-Origin', '*')
            ->header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS')
            ->header('Access-Control-Allow-Headers', 'Content-Type, Accept, Authorization, X-Requested-With');
    })->where('any', '.*');
    
});
'@
    
    # Write file with UTF8 without BOM
    $utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText("backend/routes/api.php", $cleanRoutes, $utf8NoBomEncoding)
    
    Write-Host "✅ Created clean API routes without BOM" -ForegroundColor Green
}

function Clear-Laravel-Caches {
    Write-Host "🧹 Clearing Laravel caches..." -ForegroundColor Yellow
    
    Push-Location "backend"
    
    # Clear all possible caches
    php artisan config:clear 2>$null
    php artisan cache:clear 2>$null
    php artisan route:clear 2>$null
    php artisan view:clear 2>$null
    
    # Remove bootstrap cache files manually
    $cacheFiles = @(
        "bootstrap/cache/config.php",
        "bootstrap/cache/routes-v7.php", 
        "bootstrap/cache/services.php"
    )
    
    foreach ($file in $cacheFiles) {
        if (Test-Path $file) {
            Remove-Item $file -Force -ErrorAction SilentlyContinue
            Write-Host "   Removed $file" -ForegroundColor Gray
        }
    }
    
    Write-Host "✅ All caches cleared" -ForegroundColor Green
    
    Pop-Location
}

function Test-Clean-Response {
    Write-Host "🧪 Testing clean response..." -ForegroundColor Blue
    
    # Wait a moment for server to reload
    Start-Sleep 2
    
    try {
        $loginData = @{
            email = "admin@bankqu.com"
            password = "admin123"
        } | ConvertTo-Json
        
        # Test with Invoke-WebRequest to see raw response
        $response = Invoke-WebRequest -Uri "http://localhost:8000/api/login" -Method POST -Body $loginData -ContentType "application/json" -UseBasicParsing -TimeoutSec 5
        
        $rawContent = $response.Content
        Write-Host "   Raw response first 50 chars: $($rawContent.Substring(0, [Math]::Min(50, $rawContent.Length)))" -ForegroundColor Gray
        
        # Check for BOM characters
        if ($rawContent.StartsWith("ï»¿")) {
            Write-Host "❌ BOM characters still present" -ForegroundColor Red
            return $false
        } else {
            Write-Host "✅ No BOM characters detected" -ForegroundColor Green
        }
        
        # Try to parse JSON
        $jsonData = $rawContent | ConvertFrom-Json
        
        if ($jsonData.success -and $jsonData.data.access_token) {
            Write-Host "✅ JSON parsing successful!" -ForegroundColor Green
            Write-Host "   User: $($jsonData.data.user.name)" -ForegroundColor Gray
            Write-Host "   Token: $($jsonData.data.access_token.Substring(0,20))..." -ForegroundColor Gray
            return $true
        } else {
            Write-Host "❌ JSON structure incorrect" -ForegroundColor Red
            return $false
        }
        
    } catch {
        Write-Host "❌ Test failed: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Show-Manual-Fix {
    Write-Host ""
    Write-Host "🔧 Manual Fix Alternative:" -ForegroundColor Yellow
    Write-Host "==========================" -ForegroundColor Blue
    Write-Host ""
    Write-Host "1. Delete and recreate api.php file:" -ForegroundColor Yellow
    Write-Host "   del backend\\routes\\api.php" -ForegroundColor Gray
    Write-Host "   Create new file with Notepad++ or VS Code" -ForegroundColor Gray
    Write-Host "   Save with UTF-8 encoding (no BOM)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "2. Or restart backend with output buffering:" -ForegroundColor Yellow
    Write-Host "   cd backend" -ForegroundColor Gray
    Write-Host "   php -d output_buffering=0 artisan serve" -ForegroundColor Gray
    Write-Host ""
    Write-Host "3. Test in Postman/browser:" -ForegroundColor Yellow
    Write-Host "   POST http://localhost:8000/api/login" -ForegroundColor Blue
    Write-Host "   Should return clean JSON without strange characters" -ForegroundColor Gray
}

# Main execution
Write-Host "🚀 Starting UTF-8 BOM fix..." -ForegroundColor Green
Write-Host ""

Write-Host "The issue: Response has UTF-8 BOM characters (ï»¿)" -ForegroundColor Yellow
Write-Host "This breaks JSON parsing in frontend" -ForegroundColor Yellow
Write-Host ""

# 1. Fix UTF-8 encoding
Fix-UTF8-Encoding

# 2. Clear all caches
Clear-Laravel-Caches

Write-Host ""
Write-Host "⏳ Please restart backend server..." -ForegroundColor Yellow
Write-Host "   1. Stop current backend (Ctrl+C)" -ForegroundColor Gray
Write-Host "   2. cd backend && php artisan serve" -ForegroundColor Gray
Write-Host ""

$restartDone = Read-Host "Backend restarted? (y/n)"

if ($restartDone -eq "y" -or $restartDone -eq "Y") {
    Write-Host ""
    
    # 3. Test clean response
    $responseClean = Test-Clean-Response
    
    if ($responseClean) {
        Write-Host ""
        Write-Host "🎉 UTF-8 BOM fix successful!" -ForegroundColor Green
        Write-Host "=============================" -ForegroundColor Blue
        Write-Host "✅ No BOM characters in response" -ForegroundColor Green
        Write-Host "✅ JSON parsing working" -ForegroundColor Green
        Write-Host "✅ Login response format correct" -ForegroundColor Green
        Write-Host ""
        Write-Host "🧪 Try frontend login now:" -ForegroundColor Yellow
        Write-Host "   http://localhost:3000" -ForegroundColor Blue
        Write-Host "   Email: admin@bankqu.com" -ForegroundColor Gray
        Write-Host "   Password: admin123" -ForegroundColor Gray
        Write-Host ""
        Write-Host "Should work without network errors!" -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "❌ BOM characters still present" -ForegroundColor Red
        Show-Manual-Fix
    }
} else {
    Write-Host ""
    Write-Host "⚠️ Please restart backend to apply UTF-8 fix" -ForegroundColor Yellow
    Show-Manual-Fix
}

Write-Host ""
Write-Host "🔧 UTF-8 BOM fix completed!" -ForegroundColor Green