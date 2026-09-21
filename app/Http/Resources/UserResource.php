<?php

namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;

class UserResource extends JsonResource
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
            'email' => $this->email,
            'phone' => $this->phone,
            'role' => $this->role,
            'is_active' => (bool) $this->is_active,
            'trial_ends_at' => $this->trial_ends_at?->toISOString(),
            'avatar_url' => $this->avatar_path
                ? (filter_var($this->avatar_path, FILTER_VALIDATE_URL)
                    ? $this->avatar_path
                    : url(ltrim($this->avatar_path, '/')))
                : null,
            'pharmacy' => $this->when($this->role === 'pharmacy_owner', function () {
                return $this->pharmacy ? new PharmacyResource($this->pharmacy) : null;
            }),
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}