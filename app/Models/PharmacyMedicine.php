<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class PharmacyMedicine extends Model
{
    protected $table = 'pharmacy_medicines';

    protected $fillable = [
        'pharmacy_id',
        'medicine_id',
        'quantity',
        'price',
        'discount_percentage',
        'expiration_date',
        'barcode',
        'is_available',
        'is_donation',
        'is_near_expiry',
    ];

    protected $casts = [
        'price' => 'float',
        'discount_percentage' => 'integer',
        'is_available' => 'boolean',
        'is_donation' => 'boolean',
        'is_near_expiry' => 'boolean',
        'expiration_date' => 'date:Y-m-d',
    ];

    public function pharmacy(): BelongsTo
    {
        return $this->belongsTo(Pharmacy::class);
    }

    public function medicine(): BelongsTo
    {
        return $this->belongsTo(Medicine::class);
    }
}