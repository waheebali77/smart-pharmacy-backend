<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Carbon\CarbonInterface;
use Illuminate\Support\Carbon;

/**
 * @property int $id
 * @property int $user_id
 * @property string $name
 * @property string $address
 * @property string|null $phone
 * @property float|null $latitude
 * @property float|null $longitude
 * @property string|null $opening_time
 * @property string|null $closing_time
 * @property bool $is_manually_closed
 * @property string|null $manual_status
 * @property string $status
 * @property string $license_number
 * @property \Illuminate\Support\Carbon $created_at
 * @property \Illuminate\Support\Carbon $updated_at
 */
class Pharmacy extends Model
{
    protected $fillable = ['user_id', 'name', 'address', 'phone', 'latitude', 'longitude', 'opening_time', 'closing_time', 'is_manually_closed', 'manual_status', 'status', 'license_number', 'images'];

    protected $casts = [
        'images' => 'array',
        'is_manually_closed' => 'boolean',
    ];

    protected static function booted(): void
    {
        static::creating(function (Pharmacy $pharmacy): void {
            $pharmacy->opening_time ??= '08:00:00';
            $pharmacy->closing_time ??= '22:00:00';
            $pharmacy->is_manually_closed ??= false;
            $pharmacy->manual_status ??= 'open';
            $pharmacy->status ??= 'open';
        });
    }

    public function isOpenNow(?CarbonInterface $now = null): bool
    {
        if ($this->manual_status !== null) {
            return $this->manual_status === 'open';
        }

        if ($this->is_manually_closed) {
            return false;
        }

        return self::isWithinOpeningHours($this->opening_time, $this->closing_time, $now);
    }

    public static function isWithinOpeningHours(?string $openingTime, ?string $closingTime, ?CarbonInterface $now = null): bool
    {
        if (!$openingTime || !$closingTime) {
            return false;
        }

        $now ??= Carbon::now();
        $currentMinutes = ($now->hour * 60) + $now->minute;
        $openingMinutes = ((int) substr($openingTime, 0, 2) * 60) + (int) substr($openingTime, 3, 2);
        $closingMinutes = ((int) substr($closingTime, 0, 2) * 60) + (int) substr($closingTime, 3, 2);

        if ($openingMinutes === $closingMinutes) {
            return true;
        }

        return $openingMinutes < $closingMinutes
            ? $currentMinutes >= $openingMinutes && $currentMinutes < $closingMinutes
            : $currentMinutes >= $openingMinutes || $currentMinutes < $closingMinutes;
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(AppUser::class, 'user_id');
    }

    public function medicines(): BelongsToMany
    {
        return $this->belongsToMany(Medicine::class, 'pharmacy_medicines')
            ->withPivot(['quantity', 'price', 'discount_percentage', 'expiration_date', 'barcode', 'is_available', 'is_donation', 'is_near_expiry'])
            ->withTimestamps();
    }

    public function offers(): HasMany
    {
        return $this->hasMany(Offer::class);
    }

    public function orders(): HasMany
    {
        return $this->hasMany(Order::class);
    }
}