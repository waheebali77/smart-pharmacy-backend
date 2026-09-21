<?php

namespace App\Services;

use App\Repositories\PharmacyRepository;
use App\Http\Resources\Customer\PharmacyResource;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;
use Illuminate\Database\Eloquent\Collection;

class PharmacyService
{
    protected PharmacyRepository $repository;

    public function __construct(PharmacyRepository $repository)
    {
        $this->repository = $repository;
    }

    /**
     * Get all pharmacies with optional filters.
     *
     * @param array $filters
     * @return AnonymousResourceCollection
     */
    public function getAll(array $filters = []): AnonymousResourceCollection
    {
        $pharmacies = $this->repository->getAll($filters);
        return PharmacyResource::collection($pharmacies);
    }

    /**
     * Get a pharmacy by ID.
     *
     * @param int $id
     * @return PharmacyResource|null
     */
    public function getById(int $id)
    {
        $pharmacy = $this->repository->findById($id);
        return $pharmacy ? new PharmacyResource($pharmacy) : null;
    }

    /**
     * Get pharmacies near a given latitude and longitude.
     *
     * @param float $latitude
     * @param float $longitude
     * @param float $radiusInKm (optional, default 10 km)
     * @return AnonymousResourceCollection
     */
    public function getNearby(float $latitude, float $longitude, float $radiusInKm = 10): Collection
    {
        $pharmacies = $this->repository->getNearby($latitude, $longitude, $radiusInKm);
        return $pharmacies;
    }
}