<?php

namespace App\Repositories;

use App\Models\Offer;
use Illuminate\Support\Collection;

class OfferRepository
{
    /**
     * Get all offers with optional filters.
     *
     * @param array $filters
     * @return Collection
     */
    public function getAll(array $filters = []): Collection
    {
        $query = Offer::with('pharmacy');

        // Filter by pharmacy ID
        if (isset($filters['pharmacy_id'])) {
            $query->where('pharmacy_id', $filters['pharmacy_id']);
        }

        // Filter by active offers (current date between start and end)
        if (isset($filters['active']) && $filters['active']) {
            $query->whereDate('start_date', '<=', now())
                  ->whereDate('end_date', '>=', now());
        }

        return $query->get();
    }

    /**
     * Get an offer by ID.
     *
     * @param int $id
     * @return Offer|null
     */
    public function findById(int $id)
    {
        return Offer::with('pharmacy')->find($id);
    }

    /**
     * Get featured offers (active offers, maybe limited).
     *
     * @param int $limit
     * @return Collection
     */
    public function getFeatured(int $limit = 10): Collection
    {
        return Offer::whereDate('start_date', '<=', now())
                    ->whereDate('end_date', '>=', now())
                    ->with('pharmacy')
                    ->limit($limit)
                    ->get();
    }
}