<?php

namespace App\Http\Requests\Owner;

class UploadMedicineImageRequest extends OwnerRequest
{
    public function rules(): array
    {
        return [
            'image' => ['required', 'image', 'mimes:jpeg,png,jpg,gif,svg', 'max:2048'],
        ];
    }
}
