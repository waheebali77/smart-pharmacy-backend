<?php

namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;

class PackageResource extends JsonResource
{
    public function toArray($request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'price' => (float) $this->price,
            'duration_in_days' => (int) $this->duration_in_days,
            'description' => $this->description,
            'is_active' => (bool) $this->is_active,
        ];
    }
}
