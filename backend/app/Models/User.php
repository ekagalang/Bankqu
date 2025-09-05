<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    protected $fillable = [
        'name', 'email', 'password', 'phone', 'monthly_income'
    ];

    protected $hidden = [
        'password', 'remember_token',
    ];

    protected $casts = [
        'email_verified_at' => 'datetime',
        'monthly_income' => 'decimal:2',
    ];

    public function accounts()
    {
        return $this->hasMany(Account::class);
    }

    public function transactions()
    {
        return $this->hasMany(Transaction::class);
    }

    public function categories()
    {
        return $this->hasMany(Category::class);
    }

    public function investments()
    {
        return $this->hasMany(Investment::class);
    }

    public function budgets()
    {
        return $this->hasMany(Budget::class);
    }

    public function getTotalBalanceAttribute()
    {
        return $this->accounts()->sum('balance');
    }

    public function getTotalInvestmentsAttribute()
    {
        return $this->investments()->sum(\DB::raw('shares * current_price'));
    }

    public function getNetWorthAttribute()
    {
        return $this->total_balance + $this->total_investments;
    }
}