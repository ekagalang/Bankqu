# Final BOM Fix - Remove UTF-8 BOM Characters
Write-Host "🔧 Final BOM Fix..." -ForegroundColor Cyan
Write-Host "===================" -ForegroundColor Blue

function Create-Clean-Routes {
    Write-Host "📝 Creating completely clean routes..." -ForegroundColor Yellow
    
    # Delete existing file first
    $routesPath = "backend/routes/api.php"
    if (Test-Path $routesPath) {
        Remove-Item $routesPath -Force
        Write-Host "✅ Deleted existing api.php" -ForegroundColor Green
    }
    
    # Create new file content as bytes to avoid any encoding issues
    $routesContent = '<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::get(''/health'', function () {
    return response()->json([
        ''status'' => ''healthy'',
        ''timestamp'' => now()->toISOString(),
    ], 200, [
        ''Access-Control-Allow-Origin'' => ''*'',
        ''Access-Control-Allow-Methods'' => ''GET, POST, OPTIONS'',
        ''Access-Control-Allow-Headers'' => ''Content-Type, Accept, Authorization'',
        ''Content-Type'' => ''application/json; charset=utf-8''
    ]);
});

Route::post(''/login'', function (Request $request) {
    if (!$request->email || !$request->password) {
        return response()->json([
            ''success'' => false,
            ''message'' => ''Email and password are required''
        ], 422, [
            ''Access-Control-Allow-Origin'' => ''*'',
            ''Content-Type'' => ''application/json; charset=utf-8''
        ]);
    }
    
    return response()->json([
        ''success'' => true,
        ''message'' => ''Login successful'',
        ''data'' => [
            ''user'' => [
                ''id'' => 1,
                ''name'' => ''Admin BankQu'',
                ''email'' => $request->email,
                ''email_verified_at'' => now()->toISOString()
            ],
            ''access_token'' => ''demo-token-'' . time() . ''-'' . rand(1000, 9999),
            ''token_type'' => ''Bearer''
        ]
    ], 200, [
        ''Access-Control-Allow-Origin'' => ''*'',
        ''Access-Control-Allow-Methods'' => ''GET, POST, OPTIONS'',
        ''Access-Control-Allow-Headers'' => ''Content-Type, Accept, Authorization'',
        ''Content-Type'' => ''application/json; charset=utf-8''
    ]);
});

Route::options(''/login'', function () {
    return response('''', 200, [
        ''Access-Control-Allow-Origin'' => ''*'',
        ''Access-Control-Allow-Methods'' => ''GET, POST, OPTIONS'',
        ''Access-Control-Allow-Headers'' => ''Content-Type, Accept, Authorization''
    ]);
});

Route::options(''/health'', function () {
    return response('''', 200, [
        ''Access-Control-Allow-Origin'' => ''*'',
        ''Access-Control-Allow-Methods'' => ''GET, POST, OPTIONS'',
        ''Access-Control-Allow-Headers'' => ''Content-Type, Accept, Authorization''
    ]);
});

Route::options(''/{any}'', function () {
    return response('''', 200, [
        ''Access-Control-Allow-Origin'' => ''*'',
        ''Access-Control-Allow-Methods'' => ''GET, POST, PUT, DELETE, OPTIONS'',
        ''Access-Control-Allow-Headers'' => ''Content-Type, Accept, Authorization, X-Requested-With''
    ]);
})->where(''any'', ''.*'');'
    
    # Write as pure ASCII bytes to avoid any BOM
    $bytes = [System.Text.Encoding]::ASCII.GetBytes($routesContent)
    [System.IO.File]::WriteAllBytes($routesPath, $bytes)
    
    Write-Host "✅ Created clean routes with ASCII encoding" -ForegroundColor Green
}

function Alternative-PHP-Approach {
    Write-Host "🔄 Alternative: Creating routes via PHP script..." -ForegroundColor Yellow
    
    $phpScript = @'
<?php
// Create clean routes file without BOM

$content = '<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::get("/health", function () {
    return response()->json([
        "status" => "healthy",
        "timestamp" => now()->toISOString(),
    ], 200, [
        "Access-Control-Allow-Origin" => "*",
        "Access-Control-Allow-Methods" => "GET, POST, OPTIONS",
        "Access-Control-Allow-Headers" => "Content-Type, Accept, Authorization",
        "Content-Type" => "application/json; charset=utf-8"
    ]);
});

Route::post("/login", function (Request $request) {
    if (!$request->email || !$request->password) {
        return response()->json([
            "success" => false,
            "message" => "Email and password are required"
        ], 422, [
            "Access-Control-Allow-Origin" => "*",
            "Content-Type" => "application/json; charset=utf-8"
        ]);
    }
    
    return response()->json([
        "success" => true,
        "message" => "Login successful",
        "data" => [
            "user" => [
                "id" => 1,
                "name" => "Admin BankQu",
                "email" => $request->email,
                "email_verified_at" => now()->toISOString()
            ],
            "access_token" => "demo-token-" . time() . "-" . rand(1000, 9999),
            "token_type" => "Bearer"
        ]
    ], 200, [
        "Access-Control-Allow-Origin" => "*",
        "Access-Control-Allow-Methods" => "GET, POST, OPTIONS",
        "Access-Control-Allow-Headers" => "Content-Type, Accept, Authorization",
        "Content-Type" => "application/json; charset=utf-8"
    ]);
});

Route::options("/{any}", function () {
    return response("", 200, [
        "Access-Control-Allow-Origin" => "*",
        "Access-Control-Allow-Methods" => "GET, POST, PUT, DELETE, OPTIONS",
        "Access-Control-Allow-Headers" => "Content-Type, Accept, Authorization, X-Requested-With"
    ]);
})->where("any", ".*");';

// Write without BOM
file_put_contents("routes/api.php", $content);
echo "Clean routes file created\n";
?>
'@
    
    $phpScript | Set-Content "backend/create_routes.php" -Encoding UTF8
    
    Push-Location "backend"
    $result = php create_routes.php 2>&1
    Write-Host "   PHP script result: $result" -ForegroundColor Gray
    Remove-Item "create_routes.php" -ErrorAction SilentlyContinue
    Pop-Location
    
    Write-Host "✅ Created routes via PHP script" -ForegroundColor Green
}

function Add-Output-Buffering {
    Write-Host "🔄 Adding output buffering to prevent BOM..." -ForegroundColor Yellow
    
    # Add ob_clean() to routes to clear any output buffer
    $cleanRoutes = @'
<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

// Clear output buffer to prevent BOM
if (ob_get_level()) {
    ob_clean();
}

Route::get('/health', function () {
    // Clear any output buffer
    if (ob_get_level()) ob_clean();
    
    return response()->json([
        'status' => 'healthy',
        'timestamp' => now()->toISOString(),
    ])->header('Access-Control-Allow-Origin', '*')
      ->header('Content-Type', 'application/json; charset=utf-8');
});

Route::post('/login', function (Request $request) {
    // Clear any output buffer
    if (ob_get_level()) ob_clean();
    
    if (!$request->email || !$request->password) {
        return response()->json([
            'success' => false,
            'message' => 'Email and password are required'
        ], 422)->header('Access-Control-Allow-Origin', '*');
    }
    
    return response()->json([
        'success' => true,
        'message' => 'Login successful',
        'data' => [
            'user' => [
                'id' => 1,
                'name' => 'Admin BankQu',
                'email' => $request->email,
                'email_verified_at' => now()->toISOString()
            ],
            'access_token' => 'demo-token-' . time() . '-' . rand(1000, 9999),
            'token_type' => 'Bearer'
        ]
    ])->header('Access-Control-Allow-Origin', '*')
      ->header('Content-Type', 'application/json; charset=utf-8');
});

Route::options('/{any}', function () {
    return response('', 200)
        ->header('Access-Control-Allow-Origin', '*')
        ->header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS')
        ->header('Access-Control-Allow-Headers', 'Content-Type, Accept, Authorization, X-Requested-With');
})->where('any', '.*');
'@
    
    # Try writing with different encoding
    [System.IO.File]::WriteAllText("backend/routes/api.php", $cleanRoutes, [System.Text.Encoding]::UTF8)
    
    Write-Host "✅ Added output buffering to routes" -ForegroundColor Green
}

function Test-Clean-Response {
    Write-Host "🧪 Testing for BOM characters..." -ForegroundColor Blue
    
    Start-Sleep 2
    
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8000/api/health" -UseBasicParsing -TimeoutSec 5
        $content = $response.Content
        
        Write-Host "   Raw response first 20 chars: $($content.Substring(0, [Math]::Min(20, $content.Length)))" -ForegroundColor Gray
        
        # Check for BOM
        $bomBytes = [System.Text.Encoding]::UTF8.GetBytes($content)
        if ($bomBytes[0] -eq 239 -and $bomBytes[1] -eq 187 -and $bomBytes[2] -eq 191) {
            Write-Host "❌ BOM still present (EF BB BF)" -ForegroundColor Red
            return $false
        } elseif ($content.StartsWith("ï»¿")) {
            Write-Host "❌ BOM still present (visible characters)" -ForegroundColor Red
            return $false
        } else {
            Write-Host "✅ No BOM detected!" -ForegroundColor Green
            
            # Test JSON parsing
            try {
                $json = $content | ConvertFrom-Json
                Write-Host "✅ JSON parsing successful" -ForegroundColor Green
                return $true
            } catch {
                Write-Host "❌ JSON parsing still fails" -ForegroundColor Red
                return $false
            }
        }
    } catch {
        Write-Host "❌ Request failed: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Show-Manual-Steps {
    Write-Host ""
    Write-Host "🔧 Manual BOM removal steps:" -ForegroundColor Yellow
    Write-Host "============================" -ForegroundColor Blue
    Write-Host ""
    Write-Host "1. Delete backend/routes/api.php completely" -ForegroundColor Yellow
    Write-Host "2. Open VS Code or Notepad++" -ForegroundColor Yellow  
    Write-Host "3. Create new file, paste clean PHP code" -ForegroundColor Yellow
    Write-Host "4. Save as UTF-8 WITHOUT BOM" -ForegroundColor Yellow
    Write-Host "   - VS Code: Save with Encoding > UTF-8" -ForegroundColor Gray
    Write-Host "   - Notepad++: Encoding > UTF-8 (not UTF-8 BOM)" -ForegroundColor Gray
    Write-Host "5. Restart backend server" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Alternative: Use different editor (nano, vim, etc.)" -ForegroundColor Yellow
}

# Main execution
Write-Host "🚀 Starting final BOM fix..." -ForegroundColor Green
Write-Host ""

Write-Host "Problem identified: UTF-8 BOM characters in response" -ForegroundColor Red
Write-Host "Raw response starts with: ï»¿ï»¿" -ForegroundColor Red
Write-Host "This breaks JSON.parse() in frontend" -ForegroundColor Red
Write-Host ""

# Try multiple approaches
Write-Host "Attempting multiple BOM removal approaches..." -ForegroundColor Yellow

# 1. Clean routes with ASCII
Create-Clean-Routes

Write-Host ""
Write-Host "⏳ Please restart backend server..." -ForegroundColor Yellow
Write-Host "   Ctrl+C then: cd backend && php artisan serve" -ForegroundColor Gray
Write-Host ""

$restartDone = Read-Host "Backend restarted? (y/n)"

if ($restartDone -eq "y" -or $restartDone -eq "Y") {
    $bomRemoved = Test-Clean-Response
    
    if (!$bomRemoved) {
        Write-Host ""
        Write-Host "❌ First approach failed, trying PHP script approach..." -ForegroundColor Yellow
        Alternative-PHP-Approach
        
        Write-Host "⏳ Restart backend again..." -ForegroundColor Yellow
        Read-Host "Press Enter when restarted"
        
        $bomRemoved = Test-Clean-Response
    }
    
    if (!$bomRemoved) {
        Write-Host ""
        Write-Host "❌ PHP script approach failed, trying output buffering..." -ForegroundColor Yellow
        Add-Output-Buffering
        
        Write-Host "⏳ Restart backend again..." -ForegroundColor Yellow
        Read-Host "Press Enter when restarted"
        
        $bomRemoved = Test-Clean-Response
    }
    
    if ($bomRemoved) {
        Write-Host ""
        Write-Host "🎉 BOM removal successful!" -ForegroundColor Green
        Write-Host "=========================" -ForegroundColor Blue
        Write-Host "✅ No BOM characters detected" -ForegroundColor Green
        Write-Host "✅ JSON parsing working" -ForegroundColor Green
        Write-Host ""
        Write-Host "🧪 Test browser fetch again:" -ForegroundColor Yellow
        Write-Host "Should now show: ✅ API working from browser!" -ForegroundColor Green
        Write-Host ""
        Write-Host "🎯 Try frontend login now!" -ForegroundColor Yellow
        Write-Host "   http://localhost:3000" -ForegroundColor Blue
    } else {
        Write-Host ""
        Write-Host "❌ All automated approaches failed" -ForegroundColor Red
        Show-Manual-Steps
    }
}

Write-Host ""
Write-Host "🔧 Final BOM fix completed!" -ForegroundColor Green