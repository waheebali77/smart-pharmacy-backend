<?php

namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;

class OrderItemResource extends JsonResource
{
    public function toArray($request): array
    {
        return [
            'id' => $this->id,
            'medicine' => [
                'id' => $this->medicine?->id,
                'name' => $this->medicine?->name,
                'image_path' => $this->medicine?->image_path
                    ? url(ltrim($this->medicine->image_path, '/'))
                    : null,
                'price' => $this->medicine?->price !== null ? (float) $this->medicine->price : null,
                'discount_percentage' => $this->medicine?->discount_percentage,
            ],
            'quantity' => $this->quantity,
            'price' => (float) $this->price,
            'line_total' => round((float) $this->price * (int) $this->quantity, 2),
        ];
    }
}
