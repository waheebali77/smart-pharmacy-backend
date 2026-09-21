<?php

namespace App\Http\Resources\Owner;

use Illuminate\Http\Resources\Json\JsonResource;

class MedicineResource extends JsonResource
{
    public function toArray($request)
    {
        $inventory = $this->relationLoaded('pharmacyMedicines')
            ? $this->pharmacyMedicines->first()
            : null;
        $pivot = $inventory?->pivot ?? $this->pivot;
        $isAdded = $pivot !== null;
        $pivotExpiration = $pivot?->expiration_date;

        return [
            'id' => $this->id,
            'is_added' => $isAdded,
            'category_id' => $this->category_id,
            'name' => $this->name,
            'description' => $this->description,
            'price' => $pivot?->price ?? (float) $this->price,
            'discount_percentage' => $pivot?->discount_percentage ?? (int) $this->discount_percentage,
            'quantity' => $pivot?->quantity ?? $this->quantity,
            'is_available' => $isAdded && (bool) ($pivot?->is_available ?? $this->is_available),
            'is_donation' => (bool) ($pivot?->is_donation ?? false),
            'is_near_expiry' => (bool) ($pivot?->is_near_expiry ?? false),
            'expiration_date' => is_object($pivotExpiration) ? $pivotExpiration->format('Y-m-d') : ($pivotExpiration ?: $this->expiration_date),
            'barcode' => $pivot?->barcode ?? $this->barcode,
            'generic_name' => $this->generic_name,
            'manufacturer' => $this->manufacturer,
            'dosage_form' => $this->dosage_form,
            'strength' => $this->strength,
            'requires_prescription' => (bool) $this->requires_prescription,
            'image_path' => $this->image_path ? url(ltrim($this->image_path, '/')) : null,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
            'category' => [
                'id' => $this->category?->id,
                'name' => $this->category?->name,
            ],
        ];
    }
}
