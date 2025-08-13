<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Account;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Auth;

class AccountController extends Controller
{
    public function index(): JsonResponse
    {
        $accounts = Account::where('user_id', 1)->get(); // Default user for demo
        
        return response()->json([
            'success' => true,
            'data' => $accounts
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'type' => 'required|in:checking,savings,credit,investment,cash',
            'balance' => 'numeric|min:0',
            'color' => 'string|max:50',
            'description' => 'nullable|string'
        ]);

        $validated['user_id'] = 1; // Default user for demo
        $validated['color'] = $validated['color'] ?? 'blue';
        $validated['balance'] = $validated['balance'] ?? 0;

        $account = Account::create($validated);

        return response()->json([
            'success' => true,
            'message' => 'Account created successfully',
            'data' => $account
        ], 201);
    }

    public function show(Account $account): JsonResponse
    {
        return response()->json([
            'success' => true,
            'data' => $account
        ]);
    }

    public function update(Request $request, Account $account): JsonResponse
    {
        $validated = $request->validate([
            'name' => 'string|max:255',
            'type' => 'in:checking,savings,credit,investment,cash',
            'balance' => 'numeric|min:0',
            'color' => 'string|max:50',
            'description' => 'nullable|string'
        ]);

        $account->update($validated);

        return response()->json([
            'success' => true,
            'message' => 'Account updated successfully',
            'data' => $account
        ]);
    }

    public function destroy(Account $account): JsonResponse
    {
        $account->delete();

        return response()->json([
            'success' => true,
            'message' => 'Account deleted successfully'
        ]);
    }
}