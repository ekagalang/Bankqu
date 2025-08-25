<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\API\AuthController;
use App\Http\Controllers\API\AccountController;
use App\Http\Controllers\API\TransactionController;
use App\Http\Controllers\API\BudgetController;
use App\Http\Controllers\API\CategoryController;
use App\Http\Controllers\API\InvestmentController;

// Clear output buffer to prevent BOM
if (ob_get_level()) {
    ob_clean();
}

// Health check endpoint
Route::get('/health', function () {
    if (ob_get_level()) ob_clean();
    
    return response()->json([
        'status' => 'healthy',
        'timestamp' => now()->toISOString(),
    ])->header('Access-Control-Allow-Origin', '*')
      ->header('Content-Type', 'application/json; charset=utf-8');
});

// Public Auth Routes
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

// Protected routes
Route::middleware('auth:sanctum')->group(function () {
    // Auth routes
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/me', [AuthController::class, 'me']);
    
    // Account routes
    Route::apiResource('accounts', AccountController::class);
    
    // Transaction routes
    Route::apiResource('transactions', TransactionController::class);
    
    // Budget routes
    Route::apiResource('budgets', BudgetController::class);
    
    // Investment routes
    Route::apiResource('investments', InvestmentController::class);
    
    // Category routes
    Route::apiResource('categories', CategoryController::class);
});

// CORS preflight
Route::options('/{any}', function () {
    return response('', 200)
        ->header('Access-Control-Allow-Origin', '*')
        ->header('Access-Control-Allow-Methods', 'GET, POST, PUT, PATCH, DELETE, OPTIONS')
        ->header('Access-Control-Allow-Headers', 'Content-Type, Accept, Authorization, X-Requested-With');
})->where('any', '.*');