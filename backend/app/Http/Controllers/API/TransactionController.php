<?php
namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Transaction;
use App\Models\Account;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\DB;

class TransactionController extends Controller
{
    public function index(Request $request)
    {
        $query = $request->user()->transactions()
            ->with(['account', 'category'])
            ->orderBy('created_at', 'desc');

        // Filter by account
        if ($request->has('account_id')) {
            $query->where('account_id', $request->account_id);
        }

        // Filter by category
        if ($request->has('category_id')) {
            $query->where('category_id', $request->category_id);
        }

        // Filter by date range
        if ($request->has('start_date')) {
            $query->whereDate('created_at', '>=', $request->start_date);
        }
        
        if ($request->has('end_date')) {
            $query->whereDate('created_at', '<=', $request->end_date);
        }

        // Filter by type
        if ($request->has('type')) {
            $query->where('type', $request->type);
        }

        $transactions = $query->paginate(20);

        return response()->json([
            'success' => true,
            'data' => $transactions
        ]);
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'account_id' => 'required|exists:accounts,id',
            'category_id' => 'required|exists:categories,id', 
            'type' => 'required|in:income,expense,transfer',
            'amount' => 'required|numeric|min:0.01',
            'description' => 'required|string|max:500',
            'transaction_date' => 'nullable|date',
            'to_account_id' => 'nullable|exists:accounts,id',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'data' => $validator->errors()
            ], 422);
        }

        // Verify account belongs to user
        $account = Account::where('id', $request->account_id)
            ->where('user_id', $request->user()->id)
            ->first();

        if (!$account) {
            return response()->json([
                'success' => false,
                'message' => 'Account not found'
            ], 404);
        }

        // For transfer, verify to_account also belongs to user
        if ($request->type === 'transfer' && $request->to_account_id) {
            $toAccount = Account::where('id', $request->to_account_id)
                ->where('user_id', $request->user()->id)
                ->first();

            if (!$toAccount) {
                return response()->json([
                    'success' => false,
                    'message' => 'Destination account not found'
                ], 404);
            }
        }

        DB::beginTransaction();
        
        try {
            // Create transaction with default date if not provided
            $transactionData = $request->all();
            if (!isset($transactionData['transaction_date'])) {
                $transactionData['transaction_date'] = now();
            }
            
            $transaction = $request->user()->transactions()->create($transactionData);

            // Update account balance
            if ($request->type === 'income') {
                $account->increment('balance', $request->amount);
            } elseif ($request->type === 'expense') {
                $account->decrement('balance', $request->amount);
            } elseif ($request->type === 'transfer' && $request->to_account_id) {
                $account->decrement('balance', $request->amount);
                $toAccount = Account::find($request->to_account_id);
                $toAccount->increment('balance', $request->amount);
            }

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Transaction created successfully',
                'data' => $transaction->load(['account', 'category'])
            ], 201);

        } catch (\Exception $e) {
            DB::rollback();
            return response()->json([
                'success' => false,
                'message' => 'Failed to create transaction',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function show(Request $request, Transaction $transaction)
    {
        if ($transaction->user_id !== $request->user()->id) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized'
            ], 403);
        }

        return response()->json([
            'success' => true,
            'data' => $transaction->load(['account', 'category'])
        ]);
    }

    public function update(Request $request, Transaction $transaction)
    {
        if ($transaction->user_id !== $request->user()->id) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized'
            ], 403);
        }

        $validator = Validator::make($request->all(), [
            'account_id' => 'exists:accounts,id',
            'category_id' => 'exists:categories,id',
            'type' => 'in:income,expense,transfer',
            'amount' => 'numeric|min:0.01',
            'description' => 'string|max:500',
            'to_account_id' => 'nullable|exists:accounts,id',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'data' => $validator->errors()
            ], 422);
        }

        DB::beginTransaction();

        try {
            // Revert old transaction effect
            $oldAccount = $transaction->account;
            if ($transaction->type === 'income') {
                $oldAccount->decrement('balance', $transaction->amount);
            } elseif ($transaction->type === 'expense') {
                $oldAccount->increment('balance', $transaction->amount);
            } elseif ($transaction->type === 'transfer' && $transaction->to_account_id) {
                $oldAccount->increment('balance', $transaction->amount);
                $oldToAccount = Account::find($transaction->to_account_id);
                $oldToAccount->decrement('balance', $transaction->amount);
            }

            // Update transaction
            $transaction->update($request->all());

            // Apply new transaction effect
            $newAccount = Account::find($transaction->account_id);
            if ($transaction->type === 'income') {
                $newAccount->increment('balance', $transaction->amount);
            } elseif ($transaction->type === 'expense') {
                $newAccount->decrement('balance', $transaction->amount);
            } elseif ($transaction->type === 'transfer' && $transaction->to_account_id) {
                $newAccount->decrement('balance', $transaction->amount);
                $newToAccount = Account::find($transaction->to_account_id);
                $newToAccount->increment('balance', $transaction->amount);
            }

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Transaction updated successfully',
                'data' => $transaction->load(['account', 'category'])
            ]);

        } catch (\Exception $e) {
            DB::rollback();
            return response()->json([
                'success' => false,
                'message' => 'Failed to update transaction',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function destroy(Request $request, Transaction $transaction)
    {
        if ($transaction->user_id !== $request->user()->id) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized'
            ], 403);
        }

        DB::beginTransaction();

        try {
            // Revert transaction effect on account balance
            $account = $transaction->account;
            if ($transaction->type === 'income') {
                $account->decrement('balance', $transaction->amount);
            } elseif ($transaction->type === 'expense') {
                $account->increment('balance', $transaction->amount);
            } elseif ($transaction->type === 'transfer' && $transaction->to_account_id) {
                $account->increment('balance', $transaction->amount);
                $toAccount = Account::find($transaction->to_account_id);
                $toAccount->decrement('balance', $transaction->amount);
            }

            // Delete transaction
            $transaction->delete();

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Transaction deleted successfully'
            ]);

        } catch (\Exception $e) {
            DB::rollback();
            return response()->json([
                'success' => false,
                'message' => 'Failed to delete transaction',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}