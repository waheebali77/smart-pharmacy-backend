<?php

namespace App\Repositories;

use App\Models\Category;
use Illuminate\Database\Eloquent\Collection;

class CategoryRepository
{
    /**
     * Get all categories.
     *
     * @return Collection
     */
    public function getAll(): Collection
    {
        return Category::all();
    }

    /**
     * Get a category by ID.
     *
     * @param int $id
     * @return Category|null
     */
    public function findById(int $id)
    {
        return Category::find($id);
    }

    /**
     * Get medicines by category.
     *
     * @param int $categoryId
     * @return Collection
     */
    public function getMedicinesByCategory(int $categoryId): Collection
    {
        return Category::find($categoryId)->medicines;
    }
}