<?php

namespace App\Http\Resources\Owner;

use Illuminate\Http\Resources\Json\JsonResource;

class OfferResource extends JsonResource
{
    public function toArray($request)
    {
        return [
            'id' => $this->id,
            'pharmacy_id' => $this->pharmacy_id,
            'title' => $this->title,
            'description' => $this->description,
            'discount_percentage' => (int) $this->discount_percentage,
            'start_date' => $this->start_date,
            'end_date' => $this->end_date,
            'image_path' => $this->image_path
                ? (filter_var($this->image_path, FILTER_VALIDATE_URL)
                    ? $this->image_path
                    : url(ltrim($this->image_path, '/')))
                : null,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
