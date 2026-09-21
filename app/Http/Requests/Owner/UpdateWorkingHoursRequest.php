<?php

namespace App\Http\Requests\Owner;

class UpdateWorkingHoursRequest extends OwnerRequest
{
    public function rules(): array
    {
        return [
            'opening_time' => ['required', 'date_format:H:i'],
            'closing_time' => ['required', 'date_format:H:i'],
        ];
    }
}
