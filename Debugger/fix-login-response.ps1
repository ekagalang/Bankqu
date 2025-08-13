# Fix Backend Login Response Format
Write-Host "🔧 Fixing Backend Login Response..." -ForegroundColor Cyan
Write-Host "===================================" -ForegroundColor Blue

function Fix-Login-Route {
    Write-Host "🔑 Updating login route to match frontend expectations..." -ForegroundColor Yellow
    
    $fixedRoutes = @'
<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

// Add CORS headers to all responses
Route::middleware(['api'])->group(function () {
    
    // Health check
    Route::get('/health', function () {
        return response()->json([
            'status' => 'healthy',
            'timestamp' => now(),
        ])->header('Access-Control-Allow-Origin', '*')
          ->header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
          ->header('Access-Control-Allow-Headers', 'Content-Type, Accept, Authorization');
    });
    
    // Fixed login route - matches frontend expectations
    Route::post('/login', function (Request $request) {
        // Simple validation
        if (!$request->email || !$request->password) {
            return response()->json([
                'success' => false,
                'message' => 'Email and password are required'
            ], 422)->header('Access-Control-Allow-Origin', '*')
                   ->header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
                   ->header('Access-Control-Allow-Headers', 'Content-Type, Accept, Authorization');
        }
        
        // For demo - accept any email/password
        // In real app, validate against database
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
    
    // Register route (for future use)
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
    
    // Logout route
    Route::post('/logout', function (Request $request) {
        return response()->json([
            'success' => true,
            'message' => 'Logged out successfully'
        ])->header('Access-Control-Allow-Origin', '*');
    });
    
    // User profile route
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
    
    // Handle preflight OPTIONS requests
    Route::options('/{any}', function () {
        return response('', 200)
            ->header('Access-Control-Allow-Origin', '*')
            ->header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS')
            ->header('Access-Control-Allow-Headers', 'Content-Type, Accept, Authorization, X-Requested-With');
    })->where('any', '.*');
    
});
'@
    
    $fixedRoutes | Set-Content "backend/routes/api.php" -Encoding UTF8
    Write-Host "✅ Updated login route with proper response format" -ForegroundColor Green
}

function Test-Fixed-Login {
    Write-Host "🧪 Testing fixed login endpoint..." -ForegroundColor Blue
    
    try {
        $loginData = @{
            email = "admin@bankqu.com"
            password = "admin123"
        } | ConvertTo-Json
        
        $response = Invoke-RestMethod -Uri "http://localhost:8000/api/login" -Method POST -Body $loginData -ContentType "application/json" -TimeoutSec 5
        
        if ($response.success -and $response.data.access_token) {
            Write-Host "✅ Login response format correct!" -ForegroundColor Green
            Write-Host "   User: $($response.data.user.name)" -ForegroundColor Gray
            Write-Host "   Email: $($response.data.user.email)" -ForegroundColor Gray
            Write-Host "   Token: $($response.data.access_token.Substring(0,20))..." -ForegroundColor Gray
            return $true
        } else {
            Write-Host "❌ Login response missing required fields" -ForegroundColor Red
            Write-Host "   Response: $($response | ConvertTo-Json -Compress)" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "❌ Login test failed: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Show-Frontend-Test-Instructions {
    Write-Host ""
    Write-Host "🎯 Frontend Test Instructions:" -ForegroundColor Green
    Write-Host "===============================" -ForegroundColor Blue
    Write-Host ""
    Write-Host "1. Backend should be running at http://localhost:8000" -ForegroundColor Yellow
    Write-Host "2. Test login at http://localhost:3000" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Login Credentials:" -ForegroundColor Yellow
    Write-Host "   Email: admin@bankqu.com" -ForegroundColor Blue
    Write-Host "   Password: admin123" -ForegroundColor Blue
    Write-Host "   (Any email/password will work for demo)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Expected Result:" -ForegroundColor Yellow
    Write-Host "   ✅ Login successful" -ForegroundColor Green
    Write-Host "   ✅ Redirect to dashboard" -ForegroundColor Green
    Write-Host "   ✅ No console errors" -ForegroundColor Green
    Write-Host ""
    Write-Host "If still not working:" -ForegroundColor Yellow
    Write-Host "   1. Hard refresh browser: Ctrl+Shift+R" -ForegroundColor Gray
    Write-Host "   2. Check browser console for errors" -ForegroundColor Gray
    Write-Host "   3. Check Network tab for request details" -ForegroundColor Gray
}

function Check-Frontend-AuthContext {
    Write-Host "👤 Checking frontend AuthContext logic..." -ForegroundColor Yellow
    
    $authContextPath = "frontend/src/contexts/AuthContext.js"
    if (Test-Path $authContextPath) {
        $content = Get-Content $authContextPath -Raw
        
        # Check if it expects the right response structure
        if ($content -match "const \{ user, access_token \} = data\.data;") {
            Write-Host "✅ AuthContext expects correct response structure" -ForegroundColor Green
        } else {
            Write-Host "⚠️ AuthContext might have different response handling" -ForegroundColor Yellow
        }
        
        # Check API URL
        if ($content -match "const API_BASE_URL = '(.*?)';") {
            $apiUrl = $matches[1]
            Write-Host "   API URL: $apiUrl" -ForegroundColor Gray
            
            if ($apiUrl -match "localhost:8000") {
                Write-Host "✅ API URL looks correct" -ForegroundColor Green
            } else {
                Write-Host "⚠️ API URL might be wrong" -ForegroundColor Yellow
            }
        }
    }
}

# Main execution
Write-Host "🚀 Starting login response fix..." -ForegroundColor Green
Write-Host ""

# 1. Fix the login route to return proper format
Fix-Login-Route

# 2. Check frontend AuthContext
Check-Frontend-AuthContext

Write-Host ""
Write-Host "⏳ Please restart backend server..." -ForegroundColor Yellow
Write-Host "   1. Stop current backend (Ctrl+C)" -ForegroundColor Gray
Write-Host "   2. cd backend && php artisan serve" -ForegroundColor Gray
Write-Host ""

$restartDone = Read-Host "Backend restarted? (y/n)"

if ($restartDone -eq "y" -or $restartDone -eq "Y") {
    # 3. Test the fixed login
    $loginWorks = Test-Fixed-Login
    
    if ($loginWorks) {
        Write-Host ""
        Write-Host "🎉 Login response fix successful!" -ForegroundColor Green
        Write-Host "=================================" -ForegroundColor Blue
        
        Show-Frontend-Test-Instructions
    } else {
        Write-Host ""
        Write-Host "❌ Login response still not correct" -ForegroundColor Red
        Write-Host "Check backend terminal for errors" -ForegroundColor Yellow
    }
} else {
    Write-Host ""
    Write-Host "⚠️ Please restart backend to apply changes:" -ForegroundColor Yellow
    Write-Host "   Ctrl+C (stop current)" -ForegroundColor Gray
    Write-Host "   cd backend && php artisan serve" -ForegroundColor Gray
    Write-Host "   Then test login again" -ForegroundColor Gray
}

Write-Host ""
Write-Host "🔧 Login response fix completed!" -ForegroundColor Green