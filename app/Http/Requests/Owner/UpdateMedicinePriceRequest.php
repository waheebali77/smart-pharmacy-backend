<?php

namespace App\Http\Requests\Owner;

class UpdateMedicinePriceRequest extends OwnerRequest
{
    public function rules(): array
    {
        return [
            'price' => ['required', 'numeric', 'min:0'],
        ];
    }
}
