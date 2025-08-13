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