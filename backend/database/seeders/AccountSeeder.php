<?php

namespace Database\Seeders;

use App\Models\Account;
use App\Models\User;
use Illuminate\Database\Seeder;

class AccountSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Get first user (admin) to attach accounts
        $user = User::first();

        if (!$user) {
            $this->command->error('❌ No users found. Please run UserSeeder first.');
            return;
        }

        // Default Accounts
        $accounts = [
            [
                'name' => 'BCA - Rekening Utama',
                'type' => 'bank',
                'balance' => 15000000.00,
                'account_number' => '1234567890',
                'bank_name' => 'BCA',
                'description' => 'Rekening utama untuk transaksi sehari-hari'
            ],
            [
                'name' => 'Mandiri - Tabungan',
                'type' => 'bank',
                'balance' => 25000000.00,
                'account_number' => '0987654321',
                'bank_name' => 'Mandiri',
                'description' => 'Rekening tabungan untuk dana darurat'
            ],
            [
                'name' => 'Dana - E-Wallet',
                'type' => 'ewallet',
                'balance' => 500000.00,
                'account_number' => '081234567890',
                'bank_name' => 'Dana',
                'description' => 'Dompet digital untuk pembayaran online'
            ],
            [
                'name' => 'GoPay - E-Wallet',
                'type' => 'ewallet',
                'balance' => 300000.00,
                'account_number' => '081234567890',
                'bank_name' => 'GoPay',
                'description' => 'Dompet digital untuk transportasi dan belanja'
            ],
            [
                'name' => 'Kas Tunai',
                'type' => 'cash',
                'balance' => 1000000.00,
                'account_number' => null,
                'bank_name' => null,
                'description' => 'Uang tunai di dompet dan rumah'
            ],
            [
                'name' => 'Investasi Saham',
                'type' => 'investment',
                'balance' => 50000000.00,
                'account_number' => 'INV001',
                'bank_name' => 'Mirae Asset Sekuritas',
                'description' => 'Portfolio investasi saham'
            ]
        ];

        // Create accounts
        foreach ($accounts as $account) {
            Account::create([
                'user_id' => $user->id,
                'name' => $account['name'],
                'type' => $account['type'],
                'balance' => $account['balance'],
                'account_number' => $account['account_number'],
                'bank_name' => $account['bank_name'],
                'description' => $account['description'],
                'is_active' => true
            ]);
        }

        $this->command->info('✅ Default accounts created successfully!');
        $this->command->info('🏦 Total accounts: ' . count($accounts));
        $this->command->info('💰 Total balance: Rp ' . number_format(array_sum(array_column($accounts, 'balance')), 0, ',', '.'));
    }
}