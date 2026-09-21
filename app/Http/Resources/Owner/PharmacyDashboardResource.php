<?php

namespace App\Http\Resources\Owner;

use Illuminate\Http\Resources\Json\JsonResource;

class PharmacyDashboardResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return array
     */
    public function toArray($request)
    {
        return [
            'pharmacy' => new PharmacyResource($this->pharmacy),
            'total_medicines' => $this->total_medicines,
            'total_offers' => $this->total_offers,
            'open_status' => $this->pharmacy->isOpenNow() ? 'open' : 'closed',
            'manual_status' => $this->pharmacy->manual_status,
            'working_hours' => [
                'opening_time' => $this->opening_time,
                'closing_time' => $this->closing_time,
            ],
            'medicines' => MedicineResource::collection($this->medicines),
            'offers' => OfferResource::collection($this->offers),
        ];
    }
}
