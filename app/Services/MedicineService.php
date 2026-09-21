<?php

namespace App\Services;

use App\Repositories\MedicineRepository;
use App\Http\Resources\Customer\MedicineResource;
use Illuminate\Support\Collection;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

class MedicineService
{
    protected MedicineRepository $repository;

    public function __construct(MedicineRepository $repository)
    {
        $this->repository = $repository;
    }

    /**
     * Get all medicines with optional filters.
     *
     * @param array $filters
     * @return AnonymousResourceCollection
     */
    public function getAll(array $filters = []): AnonymousResourceCollection
    {
        $medicines = $this->repository->getAll($filters);
        return MedicineResource::collection($medicines);
    }

    /**
     * Get a medicine by ID.
     *
     * @param int $id
     * @return MedicineResource|null
     */
    public function getById(int $id)
    {
        $medicine = $this->repository->findById($id);
        return $medicine ? new MedicineResource($medicine) : null;
    }

    /**
     * Get medicines by category.
     *
     * @param int $categoryId
     * @return AnonymousResourceCollection
     */
    public function getByCategory(int $categoryId): AnonymousResourceCollection
    {
        $medicines = $this->repository->getByCategory($categoryId);
        return MedicineResource::collection($medicines);
    }

    /**
     * Get popular medicines.
     *
     * @param int $limit
     * @return AnonymousResourceCollection
     */
    public function getPopular(int $limit = 10): AnonymousResourceCollection
    {
        $medicines = $this->repository->getPopular($limit);
        return MedicineResource::collection($medicines);
    }
}