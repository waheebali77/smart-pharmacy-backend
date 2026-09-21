<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Governorate extends Model
{
    protected $fillable = ['country_id', 'name_ar', 'name_en'];

    public function country(): BelongsTo
    {
        return $this->belongsTo(Country::class);
    }
}
