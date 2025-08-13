<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use App\Models\User;
use App\Models\Account;
use App\Models\Transaction;
use App\Models\Investment;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        // Create default user
        $user = User::updateOrCreate([
            'email' => 'admin@bankqu.com'
        ], [
            'name' => 'Admin BankQu',
            'email' => 'admin@bankqu.com',
            'password' => Hash::make('admin123'),
            'email_verified_at' => now(),
        ]);

        // Create sample accounts
        $accounts = [
            [
                'user_id' => $user->id,
                'name' => 'Bank Mandiri',
                'type' => 'checking',
                'balance' => 15750000,
                'color' => 'blue'
            ],
            [
                'user_id' => $user->id,
                'name' => 'Bank BCA',
                'type' => 'savings',
                'balance' => 32450000,
                'color' => 'green'
            ],
            [
                'user_id' => $user->id,
                'name' => 'Kredit Mobil',
                'type' => 'credit',
                'balance' => -8500000,
                'color' => 'red'
            ]
        ];

        foreach ($accounts as $accountData) {
            Account::updateOrCreate([
                'user_id' => $accountData['user_id'],
                'name' => $accountData['name']
            ], $accountData);
        }

        // Create sample transactions
        $transactions = [
            [
                'user_id' => $user->id,
                'account_id' => 1,
                'type' => 'income',
                'amount' => 12000000,
                'description' => 'Gaji Bulanan',
                'category' => 'Salary',
                'date' => today()->subDays(3)
            ],
            [
                'user_id' => $user->id,
                'account_id' => 2,
                'type' => 'expense',
                'amount' => 750000,
                'description' => 'Belanja Groceries',
                'category' => 'Food',
                'date' => today()->subDays(2)
            ],
            [
                'user_id' => $user->id,
                'account_id' => 1,
                'type' => 'expense',
                'amount' => 2000000,
                'description' => 'Transfer ke Tabungan',
                'category' => 'Savings',
                'date' => today()->subDay()
            ],
            [
                'user_id' => $user->id,
                'account_id' => 2,
                'type' => 'income',
                'amount' => 3500000,
                'description' => 'Freelance Project',
                'category' => 'Work',
                'date' => today()
            ]
        ];

        foreach ($transactions as $transactionData) {
            Transaction::create($transactionData);
        }

        // Create sample investments
        $investments = [
            [
                'user_id' => $user->id,
                'name' => 'Saham BBRI',
                'type' => 'stock',
                'shares' => 100,
                'price' => 4850,
                'value' => 485000,
                'change_percent' => 2.5,
                'symbol' => 'BBRI'
            ],
            [
                'user_id' => $user->id,
                'name' => 'Reksadana Mandiri',
                'type' => 'mutual_fund',
                'shares' => 1000,
                'price' => 2150,
                'value' => 2150000,
                'change_percent' => -1.2
            ],
            [
                'user_id' => $user->id,
                'name' => 'Bitcoin',
                'type' => 'crypto',
                'shares' => 0.05,
                'price' => 780000000,
                'value' => 39000000,
                'change_percent' => 5.8,
                'symbol' => 'BTC'
            ]
        ];

        foreach ($investments as $investmentData) {
            Investment::updateOrCreate([
                'user_id' => $investmentData['user_id'],
                'name' => $investmentData['name']
            ], $investmentData);
        }

        echo "✅ Database seeded successfully!\n";
        echo "📊 Created:\n";
        echo "   - 1 user (admin@bankqu.com / admin123)\n";
        echo "   - " . count($accounts) . " accounts\n";
        echo "   - " . count($transactions) . " transactions\n";
        echo "   - " . count($investments) . " investments\n";
    }
}