<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Setting extends Model
{
    protected $fillable = [
        'app_name',
        'logo_path',
        'contact_email',
        'contact_phone',
        'contact_address',
        'privacy_policy',
        'terms_conditions',
    ];

    // Since we expect only one row, we can override the boot method to enforce single record
    protected static function boot()
    {
        parent::boot();

        static::creating(function ($model) {
            // If there's already a setting, prevent creating another
            if (self::count()) {
                return false;
            }
        });
    }
}