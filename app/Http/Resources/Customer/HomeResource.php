<?php

namespace App\Http\Resources\Customer;

use Illuminate\Http\Resources\Json\JsonResource;

class HomeResource extends JsonResource
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
            'featured_offers' => $this['featured_offers'],
            'categories' => $this['categories'],
            'popular_medicines' => $this['popular_medicines'],
            'nearby_pharmacies' => $this['nearby_pharmacies'],
        ];
    }
}