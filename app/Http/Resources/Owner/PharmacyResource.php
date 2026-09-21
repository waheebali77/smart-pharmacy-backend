<?php

namespace App\Http\Resources\Owner;

use Illuminate\Http\Resources\Json\JsonResource;

class PharmacyResource extends JsonResource
{
    public function toArray($request)
    {
        $images = collect($this->images ?? [])->map(function ($path) {
            return filter_var($path, FILTER_VALIDATE_URL) ? $path : url(ltrim($path, '/'));
        })->values()->all();

        return [
            'id' => $this->id,
            'name' => $this->name,
            'address' => $this->address,
            'phone' => $this->phone,
            'license_number' => $this->license_number,
            'latitude' => $this->latitude,
            'longitude' => $this->longitude,
            'status' => $this->isOpenNow() ? 'open' : 'closed',
            'is_manually_closed' => (bool) $this->is_manually_closed,
            'manual_status' => $this->manual_status,
            'opening_time' => $this->opening_time,
            'closing_time' => $this->closing_time,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
            'images' => $images,
            'image_url' => $images[count($images) - 1] ?? null,
        ];
    }
}
