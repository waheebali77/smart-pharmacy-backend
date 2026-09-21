<?php

namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;

class PharmacyResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return array|\Illuminate\Contracts\Support\Arrayable|\JsonSerializable
     */
    public function toArray($request)
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'address' => $this->address,
            'phone' => $this->phone,
            'license_number' => $this->license_number,
            'opening_time' => $this->opening_time,
            'closing_time' => $this->closing_time,
            'status' => $this->isOpenNow() ? 'open' : 'closed',
            'is_manually_closed' => (bool) $this->is_manually_closed,
            'manual_status' => $this->manual_status,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}