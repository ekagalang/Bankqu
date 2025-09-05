<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Create default admin user
        User::create([
            'name' => 'Admin User',
            'email' => 'admin@bankqu.com',
            'email_verified_at' => now(),
            'password' => Hash::make('admin123'),
            'phone' => '08123456789',
            'monthly_income' => 10000000.00, // 10 juta
        ]);

        // Create demo user
        User::create([
            'name' => 'Demo User',
            'email' => 'demo@bankqu.com',
            'email_verified_at' => now(),
            'password' => Hash::make('demo123'),
            'phone' => '08987654321',
            'monthly_income' => 5000000.00, // 5 juta
        ]);

        // Create test user
        User::create([
            'name' => 'Test User',
            'email' => 'test@bankqu.com',
            'email_verified_at' => now(),
            'password' => Hash::make('test123'),
            'phone' => '08111222333',
            'monthly_income' => 7500000.00, // 7.5 juta
        ]);

        // Create additional test users using factory
        User::factory(5)->create();

        $this->command->info('✅ Default users created successfully!');
        $this->command->info('📧 Admin: admin@bankqu.com / admin123');
        $this->command->info('📧 Demo: demo@bankqu.com / demo123');
        $this->command->info('📧 Test: test@bankqu.com / test123');
    }
}