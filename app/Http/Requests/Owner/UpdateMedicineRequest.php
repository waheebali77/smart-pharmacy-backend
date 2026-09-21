<?php

namespace App\Http\Requests\Owner;

class UpdateMedicineRequest extends OwnerRequest
{
    public function rules(): array
    {
        return [
            'category_id' => ['sometimes', 'exists:categories,id'],
            'name' => ['sometimes', 'string', 'max:255'],
            'description' => ['sometimes', 'nullable', 'string'],
            'generic_name' => ['sometimes', 'nullable', 'string', 'max:255'],
            'manufacturer' => ['sometimes', 'nullable', 'string', 'max:255'],
            'dosage_form' => ['sometimes', 'nullable', 'string', 'max:100'],
            'strength' => ['sometimes', 'nullable', 'string', 'max:100'],
            'requires_prescription' => ['sometimes', 'boolean'],
            'price' => ['sometimes', 'numeric', 'min:0'],
            'discount_percentage' => ['sometimes', 'nullable', 'integer', 'min:0', 'max:100'],
            'quantity' => ['sometimes', 'integer', 'min:0'],
            'expiration_date' => ['sometimes', 'nullable', 'date'],
            'barcode' => ['sometimes', 'nullable', 'string', 'max:100'],
            'image' => ['sometimes', 'nullable', 'image', 'mimes:jpeg,png,jpg,gif,svg', 'max:2048'],
            'is_available' => ['sometimes', 'boolean'],
            'is_donation' => ['sometimes', 'boolean'],
            'is_near_expiry' => ['sometimes', 'boolean'],
        ];
    }
}
