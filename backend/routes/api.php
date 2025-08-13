<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\API\AccountController;
use App\Http\Controllers\API\TransactionController;
use App\Http\Controllers\API\InvestmentController;

// Health check
Route::get('/health', function () {
    try {
        DB::connection()->getPdo();
        $dbStatus = 'connected';
        $userCount = DB::table('users')->count();
        $accountCount = DB::table('accounts')->count();
        $transactionCount = DB::table('transactions')->count();
    } catch (Exception $e) {
        $dbStatus = 'error: ' . $e->getMessage();
        $userCount = 0;
        $accountCount = 0;
        $transactionCount = 0;
    }
    
    return response()->json([
        'status' => 'healthy',
        'timestamp' => now(),
        'database' => $dbStatus,
        'data_counts' => [
            'users' => $userCount,
            'accounts' => $accountCount,
            'transactions' => $transactionCount
        ],
        'php_version' => PHP_VERSION,
        'laravel_version' => app()->version()
    ]);
});

// API v1 routes
Route::prefix('v1')->group(function () {
    Route::apiResource('accounts', AccountController::class);
    Route::apiResource('transactions', TransactionController::class);
    Route::apiResource('investments', InvestmentController::class);
});

// Legacy support for existing frontend calls
Route::get('/v1/accounts', [AccountController::class, 'index']);
Route::post('/v1/accounts', [AccountController::class, 'store']);
Route::delete('/v1/accounts/{account}', [AccountController::class, 'destroy']);

Route::get('/v1/transactions', [TransactionController::class, 'index']);
Route::post('/v1/transactions', [TransactionController::class, 'store']);
Route::delete('/v1/transactions/{transaction}', [TransactionController::class, 'destroy']);

Route::get('/v1/investments', [InvestmentController::class, 'index']);
Route::post('/v1/investments', [InvestmentController::class, 'store']);