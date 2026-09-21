<?php

namespace App\Http\Requests\Owner;

class UpdatePharmacyRequest extends OwnerRequest
{
    public function rules(): array
    {
        return [
            'name' => ['sometimes', 'string', 'max:255'],
            'address' => ['sometimes', 'string'],
            'phone' => ['sometimes', 'string', 'max:20'],
            'latitude' => ['sometimes', 'nullable', 'numeric', 'between:-90,90'],
            'longitude' => ['sometimes', 'nullable', 'numeric', 'between:-180,180'],
            'license_number' => ['sometimes', 'string', 'max:100'],
            'is_manually_closed' => ['sometimes', 'boolean'],
            'manual_status' => ['sometimes', 'nullable', 'in:open,closed'],
        ];
    }
}
