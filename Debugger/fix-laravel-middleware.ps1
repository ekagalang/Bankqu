# Fix Laravel Middleware Issues
Write-Host "🔧 Fixing Laravel Middleware Issues..." -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Blue

function Create-Missing-Middleware {
    Write-Host "🛡️ Creating missing middleware classes..." -ForegroundColor Yellow
    
    # Create middleware directory if not exists
    $middlewareDir = "backend/app/Http/Middleware"
    if (!(Test-Path $middlewareDir)) {
        New-Item -ItemType Directory -Path $middlewareDir -Force | Out-Null
    }
    
    # 1. EncryptCookies middleware
    $encryptCookies = @'
<?php

namespace App\Http\Middleware;

use Illuminate\Cookie\Middleware\EncryptCookies as Middleware;

class EncryptCookies extends Middleware
{
    /**
     * The names of the cookies that should not be encrypted.
     *
     * @var array<int, string>
     */
    protected $except = [
        //
    ];
}
'@
    
    $encryptCookies | Set-Content "$middlewareDir/EncryptCookies.php" -Encoding UTF8
    Write-Host "✅ Created EncryptCookies middleware" -ForegroundColor Green
    
    # 2. VerifyCsrfToken middleware
    $verifyCsrf = @'
<?php

namespace App\Http\Middleware;

use Illuminate\Foundation\Http\Middleware\VerifyCsrfToken as Middleware;

class VerifyCsrfToken extends Middleware
{
    /**
     * The URIs that should be excluded from CSRF verification.
     *
     * @var array<int, string>
     */
    protected $except = [
        'api/*',
    ];
}
'@
    
    $verifyCsrf | Set-Content "$middlewareDir/VerifyCsrfToken.php" -Encoding UTF8
    Write-Host "✅ Created VerifyCsrfToken middleware" -ForegroundColor Green
    
    # 3. RedirectIfAuthenticated middleware
    $redirectAuth = @'
<?php

namespace App\Http\Middleware;

use App\Providers\RouteServiceProvider;
use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Symfony\Component\HttpFoundation\Response;

class RedirectIfAuthenticated
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next, string ...$guards): Response
    {
        $guards = empty($guards) ? [null] : $guards;

        foreach ($guards as $guard) {
            if (Auth::guard($guard)->check()) {
                return redirect('/dashboard');
            }
        }

        return $next($request);
    }
}
'@
    
    $redirectAuth | Set-Content "$middlewareDir/RedirectIfAuthenticated.php" -Encoding UTF8
    Write-Host "✅ Created RedirectIfAuthenticated middleware" -ForegroundColor Green
    
    # 4. Authenticate middleware
    $authenticate = @'
<?php

namespace App\Http\Middleware;

use Illuminate\Auth\Middleware\Authenticate as Middleware;
use Illuminate\Http\Request;

class Authenticate extends Middleware
{
    /**
     * Get the path the user should be redirected to when they are not authenticated.
     */
    protected function redirectTo(Request $request): ?string
    {
        return $request->expectsJson() ? null : route('login');
    }
}
'@
    
    $authenticate | Set-Content "$middlewareDir/Authenticate.php" -Encoding UTF8
    Write-Host "✅ Created Authenticate middleware" -ForegroundColor Green
}

function Create-AuthController {
    Write-Host "🎮 Creating complete AuthController..." -ForegroundColor Yellow
    
    $authController = @'
<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;

class AuthController extends Controller
{
    /**
     * Login user
     */
    public function login(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'email' => 'required|email',
                'password' => 'required|string',
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Validation failed',
                    'errors' => $validator->errors()
                ], 422);
            }

            $credentials = $request->only('email', 'password');

            if (Auth::attempt($credentials)) {
                $user = Auth::user();
                $token = $user->createToken('auth_token')->plainTextToken;

                return response()->json([
                    'success' => true,
                    'message' => 'Login successful',
                    'data' => [
                        'user' => $user,
                        'access_token' => $token,
                        'token_type' => 'Bearer'
                    ]
                ]);
            }

            return response()->json([
                'success' => false,
                'message' => 'Invalid credentials'
            ], 401);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Login failed: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Register user
     */
    public function register(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'name' => 'required|string|max:255',
                'email' => 'required|email|unique:users',
                'password' => 'required|string|min:6|confirmed',
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Validation failed',
                    'errors' => $validator->errors()
                ], 422);
            }

            $user = User::create([
                'name' => $request->name,
                'email' => $request->email,
                'password' => Hash::make($request->password),
            ]);

            $token = $user->createToken('auth_token')->plainTextToken;

            return response()->json([
                'success' => true,
                'message' => 'Registration successful',
                'data' => [
                    'user' => $user,
                    'access_token' => $token,
                    'token_type' => 'Bearer'
                ]
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Registration failed: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Logout user
     */
    public function logout(Request $request)
    {
        try {
            $request->user()->currentAccessToken()->delete();

            return response()->json([
                'success' => true,
                'message' => 'Logged out successfully'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Logout failed: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get user profile
     */
    public function me(Request $request)
    {
        try {
            return response()->json([
                'success' => true,
                'data' => $request->user()
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to get user profile: ' . $e->getMessage()
            ], 500);
        }
    }
}
'@
    
    $authController | Set-Content "backend/app/Http/Controllers/AuthController.php" -Encoding UTF8
    Write-Host "✅ Created complete AuthController" -ForegroundColor Green
}

function Fix-Bootstrap-App {
    Write-Host "⚙️ Fixing bootstrap/app.php..." -ForegroundColor Yellow
    
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
        // API middleware
        $middleware->api(prepend: [
            \Laravel\Sanctum\Http\Middleware\EnsureFrontendRequestsAreStateful::class,
        ]);

        // CORS middleware
        $middleware->api(append: [
            \Illuminate\Http\Middleware\HandleCors::class,
        ]);

        // Middleware aliases
        $middleware->alias([
            'auth' => \App\Http\Middleware\Authenticate::class,
            'guest' => \App\Http\Middleware\RedirectIfAuthenticated::class,
        ]);
    })
    ->withExceptions(function (Exceptions $exceptions): void {
        //
    })->create();
'@
    
    $appBootstrap | Set-Content "backend/bootstrap/app.php" -Encoding UTF8
    Write-Host "✅ Fixed bootstrap/app.php" -ForegroundColor Green
}

function Check-API-Routes {
    Write-Host "🛣️ Ensuring API routes exist..." -ForegroundColor Yellow
    
    $apiRoutes = @'
<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');

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

// Auth routes - DIRECT endpoints (without prefix)
Route::post('/login', [AuthController::class, 'login']);
Route::post('/register', [AuthController::class, 'register']);

// Protected auth routes
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/me', [AuthController::class, 'me']);
});
'@
    
    $apiRoutes | Set-Content "backend/routes/api.php" -Encoding UTF8
    Write-Host "✅ Updated API routes" -ForegroundColor Green
}

function Clear-And-Restart {
    Write-Host "🔄 Clearing caches and testing..." -ForegroundColor Yellow
    
    Push-Location "backend"
    
    # Clear all caches
    php artisan config:clear
    php artisan cache:clear
    php artisan route:clear
    php artisan view:clear
    
    Write-Host "✅ Caches cleared" -ForegroundColor Green
    
    Pop-Location
}

function Test-Fixed-API {
    Write-Host "🧪 Testing fixed API..." -ForegroundColor Blue
    
    Start-Sleep 2  # Wait a moment
    
    # Test health endpoint
    try {
        $healthResponse = Invoke-RestMethod -Uri "http://localhost:8000/api/health" -TimeoutSec 5 -ErrorAction Stop
        Write-Host "✅ Health endpoint working: $($healthResponse.status)" -ForegroundColor Green
    } catch {
        Write-Host "❌ Health endpoint still failing" -ForegroundColor Red
        return $false
    }
    
    # Test login endpoint
    try {
        $loginData = @{
            email = "admin@bankqu.com"
            password = "admin123"
        } | ConvertTo-Json
        
        $loginResponse = Invoke-RestMethod -Uri "http://localhost:8000/api/login" -Method POST -Body $loginData -ContentType "application/json" -TimeoutSec 5 -ErrorAction Stop
        
        if ($loginResponse.success) {
            Write-Host "✅ Login endpoint working!" -ForegroundColor Green
            return $true
        } else {
            Write-Host "⚠️ Login endpoint responding but login failed: $($loginResponse.message)" -ForegroundColor Yellow
            return $false
        }
    } catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
        Write-Host "❌ Login endpoint still failing - Error $statusCode" -ForegroundColor Red
        return $false
    }
}

# Main execution
Write-Host "🚀 Starting Laravel middleware fix..." -ForegroundColor Green
Write-Host ""

# 1. Create missing middleware
Create-Missing-Middleware

# 2. Create complete AuthController
Create-AuthController

# 3. Fix bootstrap/app.php
Fix-Bootstrap-App

# 4. Ensure API routes are correct
Check-API-Routes

# 5. Clear caches
Clear-And-Restart

Write-Host ""
Write-Host "⏳ Testing fixes..." -ForegroundColor Blue

# 6. Test the fixes
$success = Test-Fixed-API

if ($success) {
    Write-Host ""
    Write-Host "🎉 Laravel fixes successful!" -ForegroundColor Green
    Write-Host "=============================" -ForegroundColor Blue
    Write-Host "✅ All middleware created" -ForegroundColor Green
    Write-Host "✅ AuthController working" -ForegroundColor Green
    Write-Host "✅ API endpoints responding" -ForegroundColor Green
    Write-Host ""
    Write-Host "🧪 Try login now at http://localhost:3000" -ForegroundColor Yellow
    Write-Host "   Email: admin@bankqu.com" -ForegroundColor Gray
    Write-Host "   Password: admin123" -ForegroundColor Gray
} else {
    Write-Host ""
    Write-Host "❌ Still having issues..." -ForegroundColor Red
    Write-Host "Check backend terminal for error messages" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Manual restart backend:" -ForegroundColor Yellow
    Write-Host "   Ctrl+C (stop current backend)" -ForegroundColor Gray
    Write-Host "   cd backend && php artisan serve" -ForegroundColor Gray
}

Write-Host ""
Write-Host "🔧 Middleware fix completed!" -ForegroundColor Green