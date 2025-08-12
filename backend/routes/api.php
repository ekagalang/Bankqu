<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\API\AuthController;

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

// Auth routes - DIRECT endpoints (without prefix)
Route::post('/login', [AuthController::class, 'login']);
Route::post('/register', [AuthController::class, 'register']);

// Protected auth routes
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/me', [AuthController::class, 'me']);
});

// Alternative auth routes with prefix (keeping old structure)
Route::prefix('auth')->group(function () {
    Route::post('/login', [AuthController::class, 'login']);
    Route::post('/register', [AuthController::class, 'register']);
    
    Route::middleware('auth:sanctum')->group(function () {
        Route::post('/logout', [AuthController::class, 'logout']);
        Route::get('/me', [AuthController::class, 'me']);
    });
});

// Data endpoints (placeholder - will be replaced with proper controllers later)
Route::prefix('v1')->middleware('auth:sanctum')->group(function () {
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