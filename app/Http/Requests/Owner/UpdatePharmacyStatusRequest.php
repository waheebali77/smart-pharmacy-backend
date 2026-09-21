<?php

namespace App\Http\Requests\Owner;

class UpdatePharmacyStatusRequest extends OwnerRequest
{
    public function rules(): array
    {
        return [
            'status' => ['required', 'string', 'in:open,closed'],
        ];
    }
}
