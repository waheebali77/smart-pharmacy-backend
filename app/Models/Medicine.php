<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Medicine extends Model
{
    protected $fillable = [
        'category_id',
        'name',
        'description',
        'generic_name',
        'manufacturer',
        'dosage_form',
        'strength',
        'price',
        'discount_percentage',
        'quantity',
        'is_available',
        'expiration_date',
        'barcode',
        'image_path',
    ];

    protected $casts = [
        'is_available' => 'boolean',
        'requires_prescription' => 'boolean',
    ];

    public function category(): \Illuminate\Database\Eloquent\Relations\BelongsTo
    {
        return $this->belongsTo(Category::class);
    }

    public function pharmacyMedicines()
    {
        return $this->belongsToMany(Pharmacy::class, 'pharmacy_medicines')
                    ->withPivot(['quantity', 'price', 'discount_percentage', 'expiration_date', 'barcode', 'is_available', 'is_donation', 'is_near_expiry'])
                    ->withTimestamps();
    }

    public function orderItems()
    {
        return $this->hasMany(OrderItem::class);
    }
}