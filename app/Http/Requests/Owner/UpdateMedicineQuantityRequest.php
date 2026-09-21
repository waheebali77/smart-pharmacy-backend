<?php

namespace App\Http\Requests\Owner;

class UpdateMedicineQuantityRequest extends OwnerRequest
{
    public function rules(): array
    {
        return [
            'quantity' => ['required', 'integer', 'min:0'],
        ];
    }
}
