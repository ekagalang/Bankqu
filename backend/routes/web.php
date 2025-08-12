<?php

use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
*/

Route::get('/', function () {
    return response()->json([
        'message' => 'BankQu Backend API',
        'api_endpoint' => url('/api'),
        'health_check' => url('/api/health'),
        'status' => 'running',
        'documentation' => 'Coming soon...'
    ]);
});
