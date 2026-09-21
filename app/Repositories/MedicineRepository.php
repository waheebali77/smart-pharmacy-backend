<?php

namespace App\Repositories;

use App\Models\Medicine;
use App\Models\Category;
use Illuminate\Database\Eloquent\Collection;

class MedicineRepository
{
    /**
     * Get all medicines with optional filters.
     *
     * @param array $filters
     * @return Collection
     */
    public function getAll(array $filters = []): Collection
    {
        $query = Medicine::query()
            ->with(['category', 'pharmacyMedicines'])
            ->where(function ($medicinesQuery) {
                $medicinesQuery->where('medicines.is_available', true)
                    ->orWhereHas('pharmacyMedicines', function ($pharmacyQuery) {
                        $pharmacyQuery->where('pharmacy_medicines.is_available', true);
                    });
            })
            ->whereHas('pharmacyMedicines', function ($pharmacyQuery) {
                $pharmacyQuery->where('pharmacies.status', 'open');
            })
            ->whereHas('pharmacyMedicines', function ($pharmacyQuery) {
                $pharmacyQuery->where('pharmacy_medicines.quantity', '>', 0)
                    ->where('pharmacy_medicines.is_available', true);
            });

        if (isset($filters['category_id'])) {
            $query->where('category_id', $filters['category_id']);
        }

        if (isset($filters['search']) && trim((string) $filters['search']) !== '') {
            $search = trim((string) $filters['search']);
            $query->where(function ($builder) use ($search) {
                $builder->where('name', 'like', '%' . $search . '%')
                    ->orWhere('generic_name', 'like', '%' . $search . '%')
                    ->orWhere('manufacturer', 'like', '%' . $search . '%')
                    ->orWhere('strength', 'like', '%' . $search . '%');
            });
        }

        if (!empty($filters['available_only'])) {
            $query->whereHas('pharmacyMedicines', function ($pharmacyQuery) {
                $pharmacyQuery->where('pharmacy_medicines.quantity', '>', 0)
                    ->where('pharmacy_medicines.is_available', true);
            });
        }

        if (!empty($filters['open_only'])) {
            $query->whereHas('pharmacyMedicines', function ($pharmacyQuery) {
                $pharmacyQuery->where('pharmacies.status', 'open');
            });
        }

        if (!empty($filters['lowest_price'])) {
            $query->join('pharmacy_medicines', 'pharmacy_medicines.medicine_id', '=', 'medicines.id')
                ->select('medicines.*')
                ->orderBy('pharmacy_medicines.price', 'asc')
                ->distinct();
        }

        return $query->get();
    }

    /**
     * Get a medicine by ID.
     *
     * @param int $id
     * @return Medicine|null
     */
    public function findById(int $id)
    {
        return Medicine::with('category')->find($id);
    }

    /**
     * Get medicines by category.
     *
     * @param int $categoryId
     * @return Collection
     */
    public function getByCategory(int $categoryId): Collection
    {
        return Medicine::where('category_id', $categoryId)->with('category')->get();
    }

    /**
     * Get popular medicines (based on quantity or arbitrary).
     *
     * @param int $limit
     * @return Collection
     */
    public function getPopular(int $limit = 10): Collection
    {
        // For now, we'll just get the most recent medicines. In a real system, we might have a view count or order count.
        return Medicine::with('category')->orderBy('created_at', 'desc')->limit($limit)->get();
    }
}