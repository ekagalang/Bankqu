<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('investments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('name');
            $table->enum('type', ['stock', 'bond', 'etf', 'crypto', 'mutual_fund']);
            $table->decimal('shares', 16, 8);
            $table->decimal('price', 15, 2);
            $table->decimal('value', 15, 2);
            $table->decimal('change_percent', 5, 2)->default(0);
            $table->string('symbol')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('investments');
    }
};