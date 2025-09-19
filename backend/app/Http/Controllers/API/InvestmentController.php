<?php
namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Investment;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class InvestmentController extends Controller
{
    public function index(Request $request)
    {
        $investments = $request->user()->investments()
            ->where('is_active', true)
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $investments
        ]);
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'type' => 'required|in:stocks,bonds,mutual_funds,crypto,real_estate,gold,other',
            'symbol' => 'nullable|string|max:20',
            'quantity' => 'required|numeric|min:0.01',
            'purchase_price' => 'required|numeric|min:0.01',
            'current_price' => 'nullable|numeric|min:0',
            'purchase_date' => 'required|date',
            'description' => 'nullable|string|max:500',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'data' => $validator->errors()
            ], 422);
        }

        $investment = $request->user()->investments()->create($request->all());

        return response()->json([
            'success' => true,
            'message' => 'Investment created successfully',
            'data' => $investment
        ], 201);
    }

    public function show(Request $request, Investment $investment)
    {
        if ($investment->user_id !== $request->user()->id) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized'
            ], 403);
        }

        return response()->json([
            'success' => true,
            'data' => $investment
        ]);
    }

    public function update(Request $request, Investment $investment)
    {
        if ($investment->user_id !== $request->user()->id) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized'
            ], 403);
        }

        $validator = Validator::make($request->all(), [
            'name' => 'string|max:255',
            'type' => 'in:stocks,bonds,mutual_funds,crypto,real_estate,gold,other',
            'symbol' => 'nullable|string|max:20',
            'quantity' => 'numeric|min:0.01',
            'purchase_price' => 'numeric|min:0.01',
            'current_price' => 'nullable|numeric|min:0',
            'purchase_date' => 'date',
            'description' => 'nullable|string|max:500',
            'is_active' => 'boolean',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'data' => $validator->errors()
            ], 422);
        }

        $investment->update($request->all());

        return response()->json([
            'success' => true,
            'message' => 'Investment updated successfully',
            'data' => $investment
        ]);
    }

    public function destroy(Request $request, Investment $investment)
    {
        if ($investment->user_id !== $request->user()->id) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized'
            ], 403);
        }

        $investment->update(['is_active' => false]);

        return response()->json([
            'success' => true,
            'message' => 'Investment deactivated successfully'
        ]);
    }
}