<?php

namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;

class ActivityLogResource extends JsonResource
{
    public function toArray($request): array
    {
        return [
            'id' => $this->id,
            'type' => $this->type,
            'data' => json_decode($this->data, true),
            'created_at' => optional($this->created_at)->toDateTimeString(),
        ];
    }
}
