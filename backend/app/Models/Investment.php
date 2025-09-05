<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Investment extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id', 'name', 'symbol', 'type', 'shares', 'buy_price',
        'current_price', 'purchase_date', 'notes'
    ];

    protected $casts = [
        'shares' => 'decimal:8',
        'buy_price' => 'decimal:2',
        'current_price' => 'decimal:2',
        'purchase_date' => 'date',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function getTotalValueAttribute()
    {
        return $this->shares * $this->current_price;
    }

    public function getGainLossAttribute()
    {
        return ($this->current_price - $this->buy_price) * $this->shares;
    }

    public function getGainLossPercentageAttribute()
    {
        if ($this->buy_price == 0) return 0;
        return (($this->current_price - $this->buy_price) / $this->buy_price) * 100;
    }
}