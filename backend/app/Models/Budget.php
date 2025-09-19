<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Budget extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id', 'category_id', 'amount', 'period', 
        'start_date', 'end_date', 'is_active'
    ];

    protected $casts = [
        'amount' => 'decimal:2',
        'start_date' => 'date',
        'end_date' => 'date',
        'is_active' => 'boolean',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function category()
    {
        return $this->belongsTo(Category::class);
    }

    public function getSpentAttribute()
    {
        return $this->category->transactions()
            ->where('type', 'expense')
            ->whereBetween('transaction_date', [$this->start_date, $this->end_date])
            ->sum('amount');
    }

    public function getRemainingAttribute()
    {
        return $this->amount - $this->spent;
    }

    public function getPercentageUsedAttribute()
    {
        if ($this->amount == 0) return 0;
        return ($this->spent / $this->amount) * 100;
    }
}