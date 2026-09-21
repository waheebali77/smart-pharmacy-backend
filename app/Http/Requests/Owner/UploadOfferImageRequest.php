<?php

namespace App\Http\Requests\Owner;

class UploadOfferImageRequest extends OwnerRequest
{
    public function rules(): array
    {
        return [
            'image' => ['required', 'image', 'mimes:jpeg,png,jpg,gif,svg', 'max:2048'],
        ];
    }
}
