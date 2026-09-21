<?php

namespace App\Http\Resources\Customer;

use Illuminate\Http\Resources\Json\JsonResource;

class MedicineResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return array
     */
    public function toArray($request)
    {
        $pharmacies = $this->pharmacyMedicines
            ->filter(function ($pharmacy) {
                return $pharmacy->pivot
                    && !empty($pharmacy->pivot->is_available)
                    && (int) ($pharmacy->pivot->quantity ?? 0) > 0;
            })
            ->map(function ($pharmacy) {
                return [
                    'pharmacy_id' => (int) $pharmacy->id,
                    'id' => $pharmacy->id,
                    'name' => $pharmacy->name,
                    'status' => $pharmacy->status,
                    'opening_time' => $pharmacy->opening_time,
                    'closing_time' => $pharmacy->closing_time,
                    'price' => (float) ($pharmacy->pivot->price ?? 0),
                    'discount_percentage' => (int) ($pharmacy->pivot->discount_percentage ?? 0),
                    'quantity' => (int) ($pharmacy->pivot->quantity ?? 0),
                    'is_available' => (bool) ($pharmacy->pivot->is_available ?? false),
                    'is_donation' => (bool) ($pharmacy->pivot->is_donation ?? false),
                    'is_near_expiry' => (bool) ($pharmacy->pivot->is_near_expiry ?? false),
                ];
            })
            ->values();

        $lowestPharmacyPrice = $pharmacies->isNotEmpty()
            ? (float) $pharmacies->min('price')
            : (float) ($this->price ?? 0);

        return [
            'id' => $this->id,
            'name' => $this->name,
            'description' => $this->description,
            'price' => $lowestPharmacyPrice,
            'discount_percentage' => (int) ($this->discount_percentage ?? 0),
            'final_price' => (float) ($lowestPharmacyPrice * (1 - (($this->discount_percentage ?? 0) / 100))),
            'quantity' => (int) ($this->quantity ?? 0),
            'expiration_date' => $this->expiration_date,
            'barcode' => $this->barcode,
            'image_path' => $this->image_path ? url(ltrim($this->image_path, '/')) : null,
            'category' => $this->category ? [
                'id' => $this->category->id,
                'name' => $this->category->name,
                'description' => $this->category->description,
            ] : null,
            'pharmacies' => $pharmacies,
        ];
    }
}