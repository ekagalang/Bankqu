<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Investment;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class InvestmentController extends Controller
{
    public function index(): JsonResponse
    {
        $investments = Investment::where('user_id', 1)->get();

        return response()->json([
            'success' => true,
            'data' => [
                'investments' => $investments
            ]
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'type' => 'required|in:stock,bond,etf,crypto,mutual_fund',
            'shares' => 'required|numeric|min:0',
            'price' => 'required|numeric|min:0',
            'symbol' => 'nullable|string|max:10'
        ]);

        $validated['user_id'] = 1; // Default user for demo
        $validated['value'] = $validated['shares'] * $validated['price'];
        $validated['change_percent'] = 0;

        $investment = Investment::create($validated);

        return response()->json([
            'success' => true,
            'message' => 'Investment created successfully',
            'data' => $investment
        ], 201);
    }
}