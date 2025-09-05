<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\DB;  // Tambahkan ini
use App\Http\Controllers\API\AuthController;

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
