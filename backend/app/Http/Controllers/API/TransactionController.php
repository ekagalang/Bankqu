<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Transaction;
use App\Models\Account;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;

class TransactionController extends Controller
{
    public function index(): JsonResponse
    {
        $transactions = Transaction::with('account')
            ->where('user_id', 1)
            ->orderBy('date', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => [
                'data' => $transactions
            ]
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'account_id' => 'required|exists:accounts,id',
            'type' => 'required|in:income,expense,transfer',
            'amount' => 'required|numeric',
            'description' => 'required|string|max:255',
            'category' => 'required|string|max:100',
            'date' => 'nullable|date'
        ]);

        $validated['user_id'] = 1; // Default user for demo
        $validated['date'] = $validated['date'] ?? today();

        DB::transaction(function () use ($validated) {
            // Create transaction
            $transaction = Transaction::create($validated);

            // Update account balance
            $account = Account::find($validated['account_id']);
            if ($validated['type'] === 'expense') {
                $account->balance -= abs($validated['amount']);
            } else {
                $account->balance += abs($validated['amount']);
            }
            $account->save();

            return $transaction;
        });

        return response()->json([
            'success' => true,
            'message' => 'Transaction created successfully'
        ], 201);
    }

    public function destroy(Transaction $transaction): JsonResponse
    {
        DB::transaction(function () use ($transaction) {
            // Reverse account balance
            $account = $transaction->account;
            if ($transaction->type === 'expense') {
                $account->balance += abs($transaction->amount);
            } else {
                $account->balance -= abs($transaction->amount);
            }
            $account->save();

            // Delete transaction
            $transaction->delete();
        });

        return response()->json([
            'success' => true,
            'message' => 'Transaction deleted successfully'
        ]);
    }
}