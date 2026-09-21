<?php

namespace App\Http\Requests\Owner;

class UpdateMedicineAvailabilityRequest extends OwnerRequest
{
    public function rules(): array
    {
        return [
            'is_available' => ['required', 'boolean'],
        ];
    }
}