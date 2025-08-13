<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Investment extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'name',
        'type',
        'shares',
        'price',
        'value',
        'change_percent',
        'symbol'
    ];

    protected $casts = [
        'shares' => 'decimal:8',
        'price' => 'decimal:2',
        'value' => 'decimal:2',
        'change_percent' => 'decimal:2',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}