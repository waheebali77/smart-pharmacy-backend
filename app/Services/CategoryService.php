<?php

namespace App\Services;

use App\Repositories\CategoryRepository;
use App\Http\Resources\Customer\CategoryResource;
use Illuminate\Support\Collection;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

class CategoryService
{
    protected CategoryRepository $repository;

    public function __construct(CategoryRepository $repository)
    {
        $this->repository = $repository;
    }

    /**
     * Get all categories.
     *
     * @return AnonymousResourceCollection
     */
    public function getAll(): AnonymousResourceCollection
    {
        $categories = $this->repository->getAll();
        return CategoryResource::collection($categories);
    }

    /**
     * Get a category by ID.
     *
     * @param int $id
     * @return CategoryResource|null
     */
    public function getById(int $id)
    {
        $category = $this->repository->findById($id);
        return $category ? new CategoryResource($category) : null;
    }

    /**
     * Get medicines by category.
     *
     * @param int $categoryId
     * @return Collection
     */
    public function getMedicinesByCategory(int $categoryId): Collection
    {
        $medicines = $this->repository->getMedicinesByCategory($categoryId);
        // We assume we have a MedicineResource, but we can also return the medicines as is or transform them.
        // For now, we'll return the medicines and let the controller transform them if needed.
        // However, to keep the service layer consistent, we can return the medicines and let the controller use MedicineResource.
        // But the method name suggests returning medicines, so we'll return the medicine models.
        // The controller can then transform them.
        return $medicines;
    }
}