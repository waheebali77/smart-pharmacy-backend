<?php

namespace App\Repositories;

use App\Models\Pharmacy;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Support\Facades\DB;

class PharmacyRepository
{
    /**
     * Get all pharmacies with optional filters.
     *
     * @param array $filters
     * @return Collection
     */
    public function getAll(array $filters = []): Collection
    {
        $query = Pharmacy::with(['user', 'medicines', 'offers']);

        $pharmacies = $query->get();

        if (isset($filters['status'])) {
            $pharmacies = $pharmacies->filter(function (Pharmacy $pharmacy) use ($filters) {
                return ($pharmacy->isOpenNow() ? 'open' : 'closed') === $filters['status'];
            });
        }

        if (!empty($filters['open_only'])) {
            $pharmacies = $pharmacies->filter(fn (Pharmacy $pharmacy) => $pharmacy->isOpenNow());
        }

        return $pharmacies->values();
    }

    /**
     * Get a pharmacy by ID.
     *
     * @param int $id
     * @return Pharmacy|null
     */
    public function findById(int $id)
    {
        return Pharmacy::with(['user', 'medicines.category', 'offers'])->find($id);
    }

    /**
     * Get pharmacies near a given latitude and longitude.
     * This is a simplified version; in production, you might use a spatial index or a service like Google Maps API.
     *
     * @param float $latitude
     * @param float $longitude
     * @param float $radiusInKm (optional, default 10 km)
     * @return Collection
     */
    public function getNearby(float $latitude, float $longitude, float $radiusInKm = 10): Collection
    {
        // Using the Haversine formula to calculate distance in MySQL
        // This is a raw query for demonstration. In a real app, you might use a package or a service.
        $earthRadius = 6371; // Earth's radius in kilometers

        return Pharmacy::select([
            'pharmacies.*',
            DB::raw("{$earthRadius} * acos(cos(radians(?)) * cos(radians(latitude)) * cos(radians(longitude) - radians(?)) + sin(radians(?)) * sin(radians(latitude))) AS distance")
        ])
        ->setBindings([$latitude, $longitude, $latitude])
        ->having('distance', '<', $radiusInKm)
        ->orderBy('distance')
        ->with(['user', 'medicines', 'offers'])
        ->get();
    }
}