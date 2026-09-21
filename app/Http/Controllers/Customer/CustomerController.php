<?php

namespace App\Http\Controllers\Customer;

use App\Http\Controllers\Controller;
use App\Services\MedicineService;
use App\Services\PharmacyService;
use App\Services\CategoryService;
use App\Services\OfferService;
use Illuminate\Http\Request;
use App\Http\Requests\Customer\MedicineSearchRequest;
use App\Http\Requests\Customer\NearbyPharmaciesRequest;
use App\Http\Resources\Customer\HomeResource;
use App\Http\Resources\Customer\MedicineResource;
use App\Http\Resources\Customer\PharmacyResource;
use App\Http\Resources\Customer\CategoryResource;
use App\Http\Resources\Customer\OfferResource;
use App\Models\Notification;
use App\Models\Offer;
use App\Models\Order;
use App\Models\OrderItem;
use App\Models\ActivityLog;
use App\Models\Medicine;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use App\Models\Pharmacy;

class CustomerController extends Controller
{
    protected MedicineService $medicineService;
    protected PharmacyService $pharmacyService;
    protected CategoryService $categoryService;
    protected OfferService $offerService;

    public function __construct(
        MedicineService $medicineService,
        PharmacyService $pharmacyService,
        CategoryService $categoryService,
        OfferService $offerService
    ) {
        $this->medicineService = $medicineService;
        $this->pharmacyService = $pharmacyService;
        $this->categoryService = $categoryService;
        $this->offerService = $offerService;
    }

    /**
     * Get home data for the customer app.
     *
     * @param Request $request
     * @return HomeResource
     */
    public function home(Request $request)
    {
        // Get latitude and longitude from request (if provided) for nearby pharmacies
        $latitude = $request->query('latitude');
        $longitude = $request->query('longitude');

        // Get featured offers (active offers)
        $featuredOffers = $this->offerService->getFeatured();

        // Get categories
        $categories = $this->categoryService->getAll();

        // Get popular medicines
        $popularMedicines = $this->medicineService->getPopular();

        // Get nearby pharmacies (if latitude and longitude are provided)
        $nearbyPharmacies = collect();
        if ($latitude && $longitude) {
            $nearbyPharmacies = $this->pharmacyService->getNearby($latitude, $longitude);
        }

        // Return a home resource that wraps all this data
        return new HomeResource([
            'featured_offers' => OfferResource::collection($featuredOffers),
            'categories' => CategoryResource::collection($categories),
            'popular_medicines' => MedicineResource::collection($popularMedicines),
            'nearby_pharmacies' => PharmacyResource::collection($nearbyPharmacies),
        ]);
    }

    /**
     * Search for medicines with filters.
     *
     * @param MedicineSearchRequest $request
     * @return MedicineResource collection
     */
    public function searchMedicines(MedicineSearchRequest $request)
    {
        $filters = $request->validated();

        $search = trim((string) ($filters['search'] ?? ''));
        $availableOnly = !empty($filters['available_only'] ?? null);
        $openOnly = !empty($filters['open_only'] ?? null);
        $lowestPrice = !empty($filters['lowest_price'] ?? null);
        $donationsOnly = !empty($filters['donations_only'] ?? null);
        $clearanceOnly = !empty($filters['clearance_only'] ?? null);

        $query = DB::table('pharmacy_medicines as pm')
            ->join('medicines as m', 'm.id', '=', 'pm.medicine_id')
            ->join('pharmacies as p', 'p.id', '=', 'pm.pharmacy_id')
            ->leftJoin('categories as c', 'c.id', '=', 'm.category_id')
            ->select(
                'pm.id as offer_id',
                'pm.medicine_id',
                'pm.pharmacy_id',
                'm.name as medicine_name',
                'm.description as medicine_description',
                'm.image_path as medicine_image',
                'm.barcode',
                'm.expiration_date',
                'm.price as medicine_base_price',
                'p.name as pharmacy_name',
                'p.address as pharmacy_address',
                'p.phone as pharmacy_phone',
                'p.status as pharmacy_status',
                'p.latitude as pharmacy_latitude',
                'p.longitude as pharmacy_longitude',
                'p.opening_time as pharmacy_opening_time',
                'p.closing_time as pharmacy_closing_time',
                'p.is_manually_closed as pharmacy_is_manually_closed',
                'p.manual_status as pharmacy_manual_status',
                'p.images as pharmacy_images',
                'c.id as category_id',
                'c.name as category_name',
                'pm.price',
                'pm.quantity',
                'pm.discount_percentage',
                'pm.is_available',
                'pm.is_donation',
                'pm.is_near_expiry',
                DB::raw('ROUND(pm.price * (1 - (pm.discount_percentage / 100)), 2) as final_price')
            );

        if (!empty($filters['category_id'] ?? null)) {
            $query->where('m.category_id', (int) $filters['category_id']);
        }

        if ($search !== '') {
            $query->where(function ($builder) use ($search) {
                $builder->where('m.name', 'like', "%{$search}%")
                    ->orWhere('m.generic_name', 'like', "%{$search}%")
                    ->orWhere('m.description', 'like', "%{$search}%")
                    ->orWhere('c.name', 'like', "%{$search}%");
            });
        }

        if ($availableOnly) {
            $query->where('pm.is_available', true)
                ->where('pm.quantity', '>', 0);
        }

        if ($donationsOnly) $query->where('pm.is_donation', true);
        if ($clearanceOnly) $query->where('pm.is_near_expiry', true);

        $offers = ($lowestPrice
                ? $query->orderByRaw('ROUND(pm.price * (1 - (pm.discount_percentage / 100)), 2) asc')
                : $query->orderBy('pm.price', 'asc'))
            ->orderBy('pm.id', 'asc')
            ->get()
            ->filter(function ($offer) use ($openOnly) {
                $isOpen = $offer->pharmacy_is_manually_closed
                    ? false
                    : ($offer->pharmacy_manual_status !== null
                        ? $offer->pharmacy_manual_status === 'open'
                        : Pharmacy::isWithinOpeningHours(
                            $offer->pharmacy_opening_time,
                            $offer->pharmacy_closing_time
                        ));

                return $isOpen;
            });

        return response()->json([
            'success' => true,
            'count' => $offers->count(),
            'data' => $offers->map(function ($offer) {
                $pharmacyImages = is_string($offer->pharmacy_images)
                    ? json_decode($offer->pharmacy_images, true)
                    : $offer->pharmacy_images;
                $pharmacyImage = is_array($pharmacyImages) && !empty($pharmacyImages)
                    ? $pharmacyImages[0]
                    : null;

                return [
                    'offer_id' => (int) $offer->offer_id,
                    'medicine_id' => (int) $offer->medicine_id,
                    'medicine' => [
                        'id' => (int) $offer->medicine_id,
                        'name' => $offer->medicine_name,
                        'description' => $offer->medicine_description,
                        'image' => $offer->medicine_image ? url(ltrim($offer->medicine_image, '/')) : null,
                        'barcode' => $offer->barcode,
                        'expiration_date' => $offer->expiration_date,
                    ],
                    'category' => $offer->category_id ? [
                        'id' => (int) $offer->category_id,
                        'name' => $offer->category_name,
                    ] : null,
                    'pharmacy' => [
                        'id' => (int) $offer->pharmacy_id,
                        'name' => $offer->pharmacy_name,
                        'address' => $offer->pharmacy_address,
                        'phone' => $offer->pharmacy_phone,
                        'latitude' => $offer->pharmacy_latitude !== null
                            ? (float) $offer->pharmacy_latitude
                            : null,
                        'longitude' => $offer->pharmacy_longitude !== null
                            ? (float) $offer->pharmacy_longitude
                            : null,
                        'status' => $offer->pharmacy_is_manually_closed
                            ? 'closed'
                            : ($offer->pharmacy_manual_status
                                ?? (Pharmacy::isWithinOpeningHours(
                                    $offer->pharmacy_opening_time,
                                    $offer->pharmacy_closing_time
                                ) ? 'open' : 'closed')),
                        'opening_time' => $offer->pharmacy_opening_time,
                        'closing_time' => $offer->pharmacy_closing_time,
                        'image' => $pharmacyImage ? url(ltrim($pharmacyImage, '/')) : null,
                    ],
                    'price' => (float) $offer->price,
                    'quantity' => (int) $offer->quantity,
                    'discount_percentage' => (int) $offer->discount_percentage,
                    'final_price' => (float) $offer->final_price,
                    'is_available' => (bool) $offer->is_available,
                    'is_donation' => (bool) $offer->is_donation,
                    'is_near_expiry' => (bool) $offer->is_near_expiry,
                ];
            })->values(),
        ]);
    }

    /**
     * Get nearby pharmacies with filters.
     *
     * @param NearbyPharmaciesRequest $request
     * @return PharmacyResource collection
     */
    public function nearbyPharmacies(NearbyPharmaciesRequest $request)
    {
        $filters = $request->validated();

        $latitude = $filters['latitude'];
        $longitude = $filters['longitude'];
        $radius = $filters['radius'] ?? 10; // default 10 km

        // Get nearby pharmacies
        $pharmacies = $this->pharmacyService->getNearby($latitude, $longitude, $radius);

        // Apply additional filters
        if (isset($filters['open_only']) && $filters['open_only']) {
            $pharmacies = $pharmacies->filter(fn ($pharmacy) => $pharmacy->isOpenNow());
        }

        // If filtering by lowest price for a specific medicine, we would need to join with pharmacy_medicines.
        // But for now, we just return the pharmacies and let the client handle sorting or we can do it in the service.
        // We'll leave the sorting to the client for simplicity.

        return PharmacyResource::collection($pharmacies);
    }

    public function allPharmacies()
    {
        return $this->pharmacyService->getAll(['status' => 'open']);
    }

    /**
     * Get details of a specific pharmacy.
     *
     * @param int $id
     * @return PharmacyResource
     */
    public function pharmacyDetails($id)
    {
        $pharmacy = $this->pharmacyService->getById($id);

        if (!$pharmacy) {
            return response()->json(['message' => 'Pharmacy not found'], 404);
        }

        return $pharmacy;
    }

    public function pharmacyMedicines(int $id)
    {
        $medicines = DB::table('pharmacy_medicines as pm')
            ->join('medicines as m', 'm.id', '=', 'pm.medicine_id')
            ->leftJoin('categories as c', 'c.id', '=', 'm.category_id')
            ->where('pm.pharmacy_id', $id)
            ->select(
                'm.id',
                'm.name',
                'm.description',
                'm.generic_name',
                'm.manufacturer',
                'm.dosage_form',
                'm.strength',
                'm.requires_prescription',
                'm.image_path',
                'm.barcode',
                'm.expiration_date',
                'c.id as category_id',
                'c.name as category_name',
                'pm.price',
                'pm.quantity',
                'pm.discount_percentage',
                'pm.is_available'
            )
            ->orderBy('m.name')
            ->get()
            ->map(function ($medicine) {
                $price = (float) $medicine->price;
                $discount = (int) $medicine->discount_percentage;

                return [
                    'id' => (int) $medicine->id,
                    'name' => $medicine->name,
                    'description' => $medicine->description,
                    'generic_name' => $medicine->generic_name,
                    'manufacturer' => $medicine->manufacturer,
                    'dosage_form' => $medicine->dosage_form,
                    'strength' => $medicine->strength,
                    'requires_prescription' => (bool) $medicine->requires_prescription,
                    'image_path' => $medicine->image_path ? url(ltrim($medicine->image_path, '/')) : null,
                    'barcode' => $medicine->barcode,
                    'expiration_date' => $medicine->expiration_date,
                    'category_id' => $medicine->category_id ? (int) $medicine->category_id : null,
                    'category' => $medicine->category_id ? [
                        'id' => (int) $medicine->category_id,
                        'name' => $medicine->category_name,
                    ] : null,
                    'price' => $price,
                    'quantity' => (int) $medicine->quantity,
                    'discount_percentage' => $discount,
                    'final_price' => round($price * (1 - ($discount / 100)), 2),
                    'is_available' => (bool) $medicine->is_available,
                ];
            });

        return response()->json([
            'success' => true,
            'data' => $medicines->values(),
        ]);
    }

    public function medicineAvailability(int $id)
    {
        $offers = DB::table('pharmacy_medicines as pm')
            ->join('medicines as m', 'm.id', '=', 'pm.medicine_id')
            ->join('pharmacies as p', 'p.id', '=', 'pm.pharmacy_id')
            ->where('pm.medicine_id', $id)
            ->select(
                'm.id',
                'm.name',
                'm.description',
                'm.generic_name',
                'm.manufacturer',
                'm.dosage_form',
                'm.strength',
                'm.image_path',
                'pm.price',
                'pm.quantity',
                'pm.discount_percentage',
                'pm.is_available',
                'p.id as pharmacy_id',
                'p.name as pharmacy_name',
                'p.address as pharmacy_address',
                'p.phone as pharmacy_phone',
                'p.status as pharmacy_status',
                'p.latitude as pharmacy_latitude',
                'p.longitude as pharmacy_longitude'
            )
            ->orderBy('pm.price')
            ->get()
            ->map(function ($offer) {
                $price = (float) $offer->price;
                $discount = (int) $offer->discount_percentage;

                return [
                    'id' => (int) $offer->id,
                    'name' => $offer->name,
                    'description' => $offer->description,
                    'generic_name' => $offer->generic_name,
                    'manufacturer' => $offer->manufacturer,
                    'dosage_form' => $offer->dosage_form,
                    'strength' => $offer->strength,
                    'image_path' => $offer->image_path ? url(ltrim($offer->image_path, '/')) : null,
                    'price' => $price,
                    'quantity' => (int) $offer->quantity,
                    'discount_percentage' => $discount,
                    'final_price' => round($price * (1 - ($discount / 100)), 2),
                    'is_available' => (bool) $offer->is_available,
                    'pharmacy' => [
                        'id' => (int) $offer->pharmacy_id,
                        'name' => $offer->pharmacy_name,
                        'address' => $offer->pharmacy_address,
                        'phone' => $offer->pharmacy_phone,
                        'status' => $offer->pharmacy_status,
                        'latitude' => (float) $offer->pharmacy_latitude,
                        'longitude' => (float) $offer->pharmacy_longitude,
                    ],
                ];
            });

        return response()->json(['success' => true, 'data' => $offers->values()]);
    }

    /**
     * Get all categories.
     *
     * @return CategoryResource collection
     */
    public function categories()
    {
        $categories = $this->categoryService->getAll();
        return CategoryResource::collection($categories);
    }

    /**
     * Get featured offers.
     *
     * @return OfferResource collection
     */
    public function featuredOffers()
    {
        $offers = $this->offerService->getFeatured();
        return OfferResource::collection($offers);
    }

    public function requestOffer(int $id)
    {
        /** @var Offer|null $offer */
        $offer = Offer::with('pharmacy')->findOrFail($id);

        $order = Order::create([
            'user_id' => Auth::id(),
            'pharmacy_id' => $offer->pharmacy_id,
            'status' => 'pending',
            'total_price' => 0,
        ]);

        /** @var \App\Models\Pharmacy|null $pharmacy */
        $pharmacy = $offer->pharmacy;

        if ($pharmacy && $pharmacy->user_id) {
            Notification::create([
                'user_id' => $pharmacy->user_id,
                'pharmacy_id' => $offer->pharmacy_id,
                'type' => 'order.requested',
                'data' => json_encode([
                    'order_id' => $order->id,
                    'message' => 'A customer requested an offer.',
                ]),
            ]);

            ActivityLog::create([
                'user_id' => Auth::id(),
                'pharmacy_id' => $offer->pharmacy_id,
                'type' => 'order.requested',
                'data' => json_encode([
                    'order_id' => $order->id,
                    'message' => 'Customer requested an offer.',
                ]),
            ]);
        }

        return response()->json([
            'success' => true,
            'message' => 'Offer request created successfully.',
            'data' => [
                'id' => $order->id,
                'status' => $order->status,
                'total_price' => (float) $order->total_price,
                'pharmacy' => $pharmacy ? [
                    'id' => $pharmacy->id,
                    'name' => $pharmacy->name,
                    'address' => $pharmacy->address,
                ] : null,
                'items' => [],
                'created_at' => $order->created_at->toDateTimeString(),
            ],
        ]);
    }

    public function requestMedicine(int $id, Request $request)
    {
        $medicine = Medicine::with('pharmacyMedicines')->findOrFail($id);
        $quantity = max(1, (int) $request->input('quantity', 1));

        $pharmacy = $medicine->pharmacyMedicines()
            ->where('pharmacies.status', 'open')
            ->wherePivot('quantity', '>', 0)
            ->wherePivot('is_available', true)
            ->first();

        if (!$pharmacy) {
            return response()->json([
                'success' => false,
                'message' => 'This medicine is not available in any pharmacy right now.',
            ], 422);
        }

        $basePrice = $pharmacy->pivot->price ?? $medicine->price;
        $discountPercentage = $pharmacy->pivot->discount_percentage
            ?? $medicine->discount_percentage
            ?? 0;
        $price = (float) $basePrice * (1 - ((float) $discountPercentage / 100));
        $total = $price * $quantity;

        $order = Order::create([
            'user_id' => Auth::id(),
            'pharmacy_id' => $pharmacy->id,
            'status' => 'pending',
            'total_price' => $total,
        ]);

        OrderItem::create([
            'order_id' => $order->id,
            'medicine_id' => $medicine->id,
            'quantity' => $quantity,
            'price' => $price,
        ]);

        $ownerId = optional($pharmacy)->user_id;
        if ($ownerId) {
            Notification::create([
                'user_id' => $ownerId,
                'pharmacy_id' => $pharmacy->id,
                'type' => 'order.requested',
                'data' => json_encode([
                    'order_id' => $order->id,
                    'message' => 'A customer requested a medicine.',
                ]),
            ]);

            ActivityLog::create([
                'user_id' => Auth::id(),
                'pharmacy_id' => $pharmacy->id,
                'type' => 'order.requested',
                'data' => json_encode([
                    'order_id' => $order->id,
                    'message' => 'Customer requested a medicine.',
                ]),
            ]);
        }

        return response()->json([
            'success' => true,
            'message' => 'Medicine request created successfully.',
            'data' => [
                'id' => $order->id,
                'status' => $order->status,
                'total_price' => (float) $order->total_price,
                'pharmacy' => [
                    'id' => $pharmacy->id,
                    'name' => $pharmacy->name,
                    'address' => $pharmacy->address,
                ],
                'items' => [[
                    'medicine_id' => $medicine->id,
                    'quantity' => $quantity,
                    'price' => $price,
                ]],
                'created_at' => $order->created_at->toDateTimeString(),
            ],
        ]);
    }

    /**
     * Get popular medicines.
     *
     * @return MedicineResource collection
     */
    public function popularMedicines()
    {
        $medicines = $this->medicineService->getPopular();
        return MedicineResource::collection($medicines);
    }
}