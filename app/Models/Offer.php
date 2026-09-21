<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

/**
 * @property int $id
 * @property int $pharmacy_id
 * @property string $title
 * @property string|null $description
 * @property float $discount_percentage
 * @property \Illuminate\Support\Carbon|null $start_date
 * @property \Illuminate\Support\Carbon|null $end_date
 * @property string|null $image_path
 * @property \Illuminate\Support\Carbon $created_at
 * @property \Illuminate\Support\Carbon $updated_at
 */
class Offer extends Model
{
    protected $fillable = [
        'pharmacy_id',
        'title',
        'description',
        'discount_percentage',
        'start_date',
        'end_date',
        'image_path',
    ];

    protected $casts = [
        'discount_percentage' => 'integer',
        'start_date' => 'date',
        'end_date' => 'date',
    ];

    /**
     * Get the pharmacy that owns the offer.
     *
     * @return BelongsTo<Pharmacy, Offer>
     */
    public function pharmacy(): BelongsTo
    {
        return $this->belongsTo(Pharmacy::class);
    }
}