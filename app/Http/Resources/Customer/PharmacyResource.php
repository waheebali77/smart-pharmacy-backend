<?php

namespace App\Http\Resources\Customer;

use Illuminate\Http\Resources\Json\JsonResource;

class PharmacyResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return array
     */
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
            'latitude' => $this->latitude,
            'longitude' => $this->longitude,
            'opening_time' => $this->opening_time,
            'closing_time' => $this->closing_time,
            'status' => $this->isOpenNow() ? 'open' : 'closed',
            'is_manually_closed' => (bool) $this->is_manually_closed,
            'manual_status' => $this->manual_status,
            'distance' => isset($this->distance) ? (float) $this->distance : null,
            'images' => $images,
            'image_url' => $images[count($images) - 1] ?? null,
            // We can include user (owner) info if needed, but for customer app maybe not.
            // 'owner' => $this->user ? [
            //     'id' => $this->user->id,
            //     'name' => $this->user->name,
            // ] : null,
            'medicines' => \App\Http\Resources\Customer\MedicineResource::collection($this->whenLoaded('medicines')),
            'offers' => \App\Http\Resources\Customer\OfferResource::collection($this->whenLoaded('offers')),
        ];
    }
}