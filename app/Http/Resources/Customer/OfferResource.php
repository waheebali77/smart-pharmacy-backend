<?php

namespace App\Http\Resources\Customer;

use Illuminate\Http\Resources\Json\JsonResource;

class OfferResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return array
     */
    public function toArray($request)
    {
        return [
            'id' => $this->id,
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
            'pharmacy' => $this->pharmacy ? [
                'id' => $this->pharmacy->id,
                'name' => $this->pharmacy->name,
            ] : null,
        ];
    }
}