<?php

namespace App\Http\Controllers;

use App\Http\Resources\Customer\OfferResource;
use App\Models\Offer;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

class OfferController extends Controller
{
    public function index(): AnonymousResourceCollection
    {
        $today = now()->toDateString();

        return OfferResource::collection(
            Offer::query()
                ->with('pharmacy')
                ->whereDate('start_date', '<=', $today)
                ->whereDate('end_date', '>=', $today)
                ->latest()
                ->get()
        );
    }
}
