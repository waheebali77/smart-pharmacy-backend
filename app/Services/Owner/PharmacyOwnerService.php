<?php

namespace App\Services\Owner;

use App\Repositories\Owner\PharmacyOwnerRepository;
use App\Http\Resources\Owner\PharmacyDashboardResource;
use App\Http\Resources\Owner\PharmacyResource;
use App\Http\Resources\Owner\MedicineResource;
use App\Http\Resources\Owner\OfferResource;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;
use Illuminate\Support\Facades\Auth;
use App\Models\Medicine;
use App\Models\Offer;
use App\Models\Pharmacy;

class PharmacyOwnerService
{
    protected PharmacyOwnerRepository $repository;

    public function __construct(PharmacyOwnerRepository $repository)
    {
        $this->repository = $repository;
    }

    public function dashboard(): PharmacyDashboardResource
    {
        $ownerId = Auth::id();
        $pharmacy = $this->repository->getPharmacyByOwnerId($ownerId);

        if (!$pharmacy) {
            throw new \RuntimeException('Pharmacy not found for owner.');
        }

        $pharmacy->load('medicines.category', 'offers');

        $dashboard = (object) [
            'pharmacy' => $pharmacy,
            'total_medicines' => $pharmacy->medicines->count(),
            'total_offers' => $pharmacy->offers->count(),
            'status' => $pharmacy->status,
            'opening_time' => $pharmacy->opening_time,
            'closing_time' => $pharmacy->closing_time,
            'medicines' => $pharmacy->medicines,
            'offers' => $pharmacy->offers,
        ];

        return new PharmacyDashboardResource($dashboard);
    }

    public function getPharmacyProfile(): PharmacyResource
    {
        $ownerId = Auth::id();
        $pharmacy = $this->repository->getPharmacyByOwnerId($ownerId);

        if (!$pharmacy) {
            throw new \RuntimeException('Pharmacy not found for owner.');
        }

        return new PharmacyResource($pharmacy);
    }

    public function updatePharmacyProfile(array $data): PharmacyResource
    {
        $ownerId = Auth::id();
        $pharmacy = $this->repository->getPharmacyByOwnerId($ownerId);

        if (!$pharmacy) {
            throw new \RuntimeException('Pharmacy not found for owner.');
        }

        $updated = $this->repository->updatePharmacy($pharmacy, $data);
        return new PharmacyResource($updated);
    }

    public function setEmergencyClose(bool $isManuallyClosed): PharmacyResource
    {
        $pharmacy = $this->repository->getPharmacyByOwnerId(Auth::id());

        if (!$pharmacy) {
            throw new \RuntimeException('Pharmacy not found for owner.');
        }

        $updated = $this->repository->updatePharmacy($pharmacy, [
            'is_manually_closed' => $isManuallyClosed,
            'manual_status' => $isManuallyClosed ? 'closed' : 'open',
            'status' => $isManuallyClosed ? 'closed' : 'open',
        ]);

        return new PharmacyResource($updated->fresh());
    }

    public function createMedicine(array $data): array
    {
        $pharmacy = $this->repository->getPharmacyByOwnerId(Auth::id());

        if (!$pharmacy) {
            throw new \RuntimeException('Pharmacy not found for owner.');
        }

        // Check if medicine already exists by name and category in the pharmacy
        $existingMedicine = $this->repository->findMedicineByNameAndCategoryInPharmacy(
            $data['name'],
            $data['category_id'],
            $pharmacy->id
        );

        // If barcode is provided, also check by barcode in the pharmacy
        if (!$existingMedicine && !empty($data['barcode'])) {
            $existingMedicine = $this->repository->findMedicineByBarcodeInPharmacy($data['barcode'], $pharmacy->id);
        }

        if ($existingMedicine) {
            // Medicine exists, return notification instead of auto-updating
            return [
                'exists' => true,
                'medicine' => new MedicineResource($existingMedicine),
                'action' => 'exists',
                'message' => 'هذا العلاج موجود مسبقاً في الصيدلية',
                'suggested_actions' => [
                    'add_quantity' => 'إضافة الكمية للعلاج الموجود',
                    'update_price' => 'تعديل سعر العلاج',
                    'update_image' => 'تعديل صورة العلاج',
                    'view_details' => 'عرض تفاصيل العلاج'
                ]
            ];
        }

        // Medicine doesn't exist, create new one
        $inventory = [
            'price' => !empty($data['is_donation']) ? 0 : ($data['price'] ?? null),
            'discount_percentage' => $data['discount_percentage'] ?? 0,
            'quantity' => (int) ($data['quantity'] ?? 0),
            'expiration_date' => $data['expiration_date'] ?? null,
            'barcode' => $data['barcode'] ?? null,
            'is_available' => (bool) ($data['is_available'] ?? false),
            'is_donation' => (bool) ($data['is_donation'] ?? false),
            'is_near_expiry' => (bool) ($data['is_near_expiry'] ?? false),
        ];
        unset($data['price'], $data['discount_percentage'], $data['quantity'], $data['expiration_date'], $data['barcode'], $data['is_available'], $data['is_donation'], $data['is_near_expiry'], $data['min_stock_alert'], $data['video']);
        $medicine = $this->repository->createMedicine($data);
        $this->repository->attachMedicineToPharmacy($pharmacy->id, $medicine->id, $inventory);

        return [
            'medicine' => new MedicineResource($medicine),
            'action' => 'created',
            'message' => 'Medicine created successfully.'
        ];
    }

    public function addCatalogMedicine(int $medicineId, array $data): MedicineResource
    {
        $pharmacy = $this->repository->getPharmacyByOwnerId(Auth::id());
        $medicine = $this->repository->getMedicineById($medicineId);
        if (!$pharmacy || !$medicine) abort(404, 'Medicine not found.');
        $data['price'] = !empty($data['is_donation']) ? 0 : $data['price'];
        $this->repository->attachMedicineToPharmacy($pharmacy->id, $medicine->id, $data);
        return new MedicineResource($this->repository->getOwnerMedicine($pharmacy->id, $medicine->id));
    }

    public function updateMedicine(Medicine $medicine, array $data): MedicineResource
    {
        $pharmacy = $this->repository->getPharmacyByOwnerId(Auth::id());
        if (!$pharmacy || !$this->repository->medicineBelongsToPharmacy($pharmacy->id, $medicine->id)) abort(404, 'Medicine not found in your pharmacy.');
        $inventory = array_intersect_key($data, array_flip(['price', 'discount_percentage', 'quantity', 'expiration_date', 'barcode', 'is_available', 'is_donation', 'is_near_expiry']));
        if (!empty($inventory['is_donation'])) $inventory['price'] = 0;
        $general = array_diff_key($data, $inventory);
        if ($general) $this->repository->updateMedicine($medicine, $general);
        if ($inventory) $this->repository->updatePharmacyMedicine($pharmacy->id, $medicine->id, $inventory);
        return new MedicineResource($this->repository->getOwnerMedicine($pharmacy->id, $medicine->id));
    }

    public function deleteMedicine(Medicine $medicine): void
    {
        $pharmacy = $this->repository->getPharmacyByOwnerId(Auth::id());
        if (!$pharmacy || !$this->repository->medicineBelongsToPharmacy($pharmacy->id, $medicine->id)) abort(404, 'Medicine not found in your pharmacy.');
        $this->repository->removeMedicineFromPharmacy($pharmacy->id, $medicine->id);
    }

    public function getMedicineById(int $id): MedicineResource
    {
        $medicine = $this->repository->getMedicineById($id);

        if (!$medicine) {
            throw new \RuntimeException('Medicine not found.');
        }

        return new MedicineResource($medicine);
    }

    public function getOwnerMedicines(): AnonymousResourceCollection
    {
        $ownerId = Auth::id();
        $medicines = $this->repository->getOwnerMedicines($ownerId);

        return MedicineResource::collection($medicines);
    }
    
    public function searchCatalogMedicines(string $search): AnonymousResourceCollection
    {
        return MedicineResource::collection($this->repository->searchCatalogMedicines($search, Auth::id()));
    }

    public function createOffer(array $data): OfferResource
    {
        $offer = $this->repository->createOffer($data);
        return new OfferResource($offer);
    }

    public function updateOffer(Offer $offer, array $data): OfferResource
    {
        $updated = $this->repository->updateOffer($offer, $data);
        return new OfferResource($updated);
    }

    public function deleteOffer(Offer $offer): void
    {
        $this->repository->deleteOffer($offer);
    }

    public function getOfferById(int $id): OfferResource
    {
        $offer = $this->repository->getOfferById($id);

        if (!$offer) {
            throw new \RuntimeException('Offer not found.');
        }

        return new OfferResource($offer);
    }

    public function getOwnerOffers(): AnonymousResourceCollection
    {
        $ownerId = Auth::id();
        $offers = $this->repository->getOwnerOffers($ownerId);

        return OfferResource::collection($offers);
    }

    public function updateMedicinePrice(Medicine $medicine, float $price): MedicineResource
    {
        return $this->updateMedicine($medicine, ['price' => $price]);
    }

    public function updateMedicineQuantity(Medicine $medicine, int $quantity): MedicineResource
    {
        return $this->updateMedicine($medicine, ['quantity' => $quantity]);
    }

    public function updateMedicineAvailability(Medicine $medicine, bool $isAvailable): MedicineResource
    {
        return $this->updateMedicine($medicine, ['is_available' => $isAvailable]);
    }

    public function setPharmacyStatus(Pharmacy $pharmacy, string $status): PharmacyResource
    {
        $updated = $this->repository->updatePharmacy($pharmacy, [
            'status' => $status,
            'manual_status' => $status,
            'is_manually_closed' => false,
        ]);
        return new PharmacyResource($updated);
    }
}
