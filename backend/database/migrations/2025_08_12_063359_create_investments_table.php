<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('investments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->string('name');
            $table->string('symbol')->nullable();
            $table->enum('type', ['saham', 'reksadana', 'crypto', 'obligasi', 'emas']);
            $table->decimal('shares', 15, 8);
            $table->decimal('buy_price', 15, 2);
            $table->decimal('current_price', 15, 2);
            $table->date('purchase_date');
            $table->text('notes')->nullable();
            $table->timestamps();
        });
    }

    public function down()
    {
        Schema::dropIfExists('investments');
    }
};