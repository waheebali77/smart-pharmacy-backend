<?php

namespace App\Http\Requests\Owner;

class UpdateEmergencyCloseRequest extends OwnerRequest
{
    public function rules(): array
    {
        return [
            'is_manually_closed' => ['required', 'boolean'],
        ];
    }
}
