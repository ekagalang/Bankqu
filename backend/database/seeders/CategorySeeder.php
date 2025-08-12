<?php

namespace Database\Seeders;

use App\Models\Category;
use App\Models\User;
use Illuminate\Database\Seeder;

class CategorySeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Get first user (admin) to attach categories
        $user = User::first();

        if (!$user) {
            $this->command->error('❌ No users found. Please run UserSeeder first.');
            return;
        }

        // Default Income Categories
        $incomeCategories = [
            [
                'name' => 'Gaji',
                'type' => 'income',
                'color' => '#10B981',
                'icon' => '💰',
                'description' => 'Pendapatan dari gaji bulanan'
            ],
            [
                'name' => 'Freelance',
                'type' => 'income',
                'color' => '#3B82F6',
                'icon' => '💻',
                'description' => 'Pendapatan dari pekerjaan freelance'
            ],
            [
                'name' => 'Investasi',
                'type' => 'income',
                'color' => '#8B5CF6',
                'icon' => '📈',
                'description' => 'Keuntungan dari investasi'
            ],
            [
                'name' => 'Bonus',
                'type' => 'income',
                'color' => '#F59E0B',
                'icon' => '🎁',
                'description' => 'Bonus atau tunjangan'
            ],
            [
                'name' => 'Lainnya',
                'type' => 'income',
                'color' => '#6B7280',
                'icon' => '💵',
                'description' => 'Pendapatan lainnya'
            ]
        ];

        // Default Expense Categories
        $expenseCategories = [
            [
                'name' => 'Makanan',
                'type' => 'expense',
                'color' => '#EF4444',
                'icon' => '🍽️',
                'description' => 'Pengeluaran untuk makanan dan minuman'
            ],
            [
                'name' => 'Transportasi',
                'type' => 'expense',
                'color' => '#F97316',
                'icon' => '🚗',
                'description' => 'Biaya transportasi dan bahan bakar'
            ],
            [
                'name' => 'Belanja',
                'type' => 'expense',
                'color' => '#EC4899',
                'icon' => '🛍️',
                'description' => 'Belanja kebutuhan dan hiburan'
            ],
            [
                'name' => 'Tagihan',
                'type' => 'expense',
                'color' => '#DC2626',
                'icon' => '📄',
                'description' => 'Listrik, air, internet, dll'
            ],
            [
                'name' => 'Kesehatan',
                'type' => 'expense',
                'color' => '#059669',
                'icon' => '🏥',
                'description' => 'Biaya kesehatan dan obat-obatan'
            ],
            [
                'name' => 'Pendidikan',
                'type' => 'expense',
                'color' => '#7C3AED',
                'icon' => '📚',
                'description' => 'Biaya pendidikan dan kursus'
            ],
            [
                'name' => 'Hiburan',
                'type' => 'expense',
                'color' => '#F59E0B',
                'icon' => '🎬',
                'description' => 'Hiburan dan rekreasi'
            ],
            [
                'name' => 'Lainnya',
                'type' => 'expense',
                'color' => '#6B7280',
                'icon' => '💸',
                'description' => 'Pengeluaran lainnya'
            ]
        ];

        // Create income categories
        foreach ($incomeCategories as $category) {
            Category::create([
                'user_id' => $user->id,
                'name' => $category['name'],
                'type' => $category['type'],
                'color' => $category['color'],
                'icon' => $category['icon'],
                'description' => $category['description'],
                'is_active' => true
            ]);
        }

        // Create expense categories
        foreach ($expenseCategories as $category) {
            Category::create([
                'user_id' => $user->id,
                'name' => $category['name'],
                'type' => $category['type'],
                'color' => $category['color'],
                'icon' => $category['icon'],
                'description' => $category['description'],
                'is_active' => true
            ]);
        }

        $this->command->info('✅ Default categories created successfully!');
        $this->command->info('📊 Income categories: ' . count($incomeCategories));
        $this->command->info('📊 Expense categories: ' . count($expenseCategories));
    }
}