<?php

namespace App\Http\Requests\Owner;

class UploadPharmacyImagesRequest extends OwnerRequest
{
    public function rules(): array
    {
        return [
            'images' => ['required', 'array'],
            'images.*' => ['required', 'image', 'mimes:jpeg,png,jpg,gif,svg', 'max:2048'],
        ];
    }
}
