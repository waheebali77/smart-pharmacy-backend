<?php

namespace App\Services;

use App\Repositories\OfferRepository;
use App\Http\Resources\Customer\OfferResource;
use Illuminate\Support\Collection;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

class OfferService
{
    protected OfferRepository $repository;

    public function __construct(OfferRepository $repository)
    {
        $this->repository = $repository;
    }

    /**
     * Get all offers with optional filters.
     *
     * @param array $filters
     * @return AnonymousResourceCollection
     */
    public function getAll(array $filters = []): AnonymousResourceCollection
    {
        $offers = $this->repository->getAll($filters);
        return OfferResource::collection($offers);
    }

    /**
     * Get an offer by ID.
     *
     * @param int $id
     * @return OfferResource|null
     */
    public function getById(int $id)
    {
        $offer = $this->repository->findById($id);
        return $offer ? new OfferResource($offer) : null;
    }

    /**
     * Get featured offers (active offers).
     *
     * @param int $limit
     * @return AnonymousResourceCollection
     */
    public function getFeatured(int $limit = 10): AnonymousResourceCollection
    {
        $offers = $this->repository->getFeatured($limit);
        return OfferResource::collection($offers);
    }
}