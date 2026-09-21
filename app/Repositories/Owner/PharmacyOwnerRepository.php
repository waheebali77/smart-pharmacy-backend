<?php

namespace App\Repositories\Owner;

use App\Models\Pharmacy;
use App\Models\Offer;
use App\Models\Medicine;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Support\Facades\Auth;

class PharmacyOwnerRepository
{
    public function getPharmacyByOwnerId(int $ownerId)
    {
        return Pharmacy::with(['medicines.category', 'offers'])->where('user_id', $ownerId)->first();
    }

    public function updatePharmacy(Pharmacy $pharmacy, array $data): Pharmacy
    {
        $pharmacy->update($data);
        return $pharmacy;
    }

    public function createMedicine(array $data): Medicine
    {
        return Medicine::create($data);
    }

    public function updateMedicine(Medicine $medicine, array $data): Medicine
    {
        $medicine->update($data);
        return $medicine;
    }

    public function deleteMedicine(Medicine $medicine): bool
    {
        return $medicine->delete();
    }

    public function getMedicineById(int $id)
    {
        return Medicine::with('category')->find($id);
    }

    public function getOwnerMedicines(int $ownerId): Collection
    {
        return Medicine::where('is_available', true)
            ->whereHas('pharmacyMedicines', function ($query) use ($ownerId) {
                $query->where('pharmacies.user_id', $ownerId);
            })
            ->with(['category', 'pharmacyMedicines' => function ($query) use ($ownerId) {
                $query->where('pharmacies.user_id', $ownerId);
            }])
            ->get();
    }

    public function searchCatalogMedicines(string $search, int $ownerId): Collection
    {
        return Medicine::query()
            ->with('category')
            ->with(['pharmacyMedicines' => function ($query) use ($ownerId) {
                $query->where('pharmacies.user_id', $ownerId);
            }])
            ->where('is_available', true)
            ->when($search !== '', fn ($query) => $query->where(function ($builder) use ($search) {
                $builder->where('name', 'like', "%{$search}%")
                    ->orWhere('generic_name', 'like', "%{$search}%")
                    ->orWhere('barcode', 'like', "%{$search}%");
            }))
            ->orderBy('name')
            ->limit(30)
            ->get();
    }

    public function attachMedicineToPharmacy(int $pharmacyId, int $medicineId, array $data): void
    {
        $pharmacy = Pharmacy::find($pharmacyId);
        if ($pharmacy) {
            $pharmacy->medicines()->syncWithoutDetaching([$medicineId => $data]);
        }
    }

    public function getOwnerMedicine(int $pharmacyId, int $medicineId): ?Medicine
    {
        return Medicine::with(['category', 'pharmacyMedicines' => function ($query) use ($pharmacyId) {
            $query->where('pharmacies.id', $pharmacyId);
        }])->whereKey($medicineId)->whereHas('pharmacyMedicines', fn ($query) => $query->where('pharmacies.id', $pharmacyId))->first();
    }

    public function medicineBelongsToPharmacy(int $pharmacyId, int $medicineId): bool
    {
        return Pharmacy::whereKey($pharmacyId)->whereHas('medicines', fn ($query) => $query->whereKey($medicineId))->exists();
    }

    public function updatePharmacyMedicine(int $pharmacyId, int $medicineId, array $data): void
    {
        $pharmacy = Pharmacy::findOrFail($pharmacyId);
        $payload = array_filter($data, fn ($value) => $value !== null);

        if (isset($payload['quantity']) && is_numeric($payload['quantity'])) {
            $payload['quantity'] = (int) $payload['quantity'];
        }

        if ($pharmacy->medicines()->whereKey($medicineId)->exists()) {
            $pharmacy->medicines()->updateExistingPivot($medicineId, $payload);
        } else {
            $pharmacy->medicines()->syncWithoutDetaching([$medicineId => $payload]);
        }

        if (array_key_exists('quantity', $payload)) {
            Medicine::whereKey($medicineId)->update(['quantity' => $payload['quantity']]);
        }
    }

    public function incrementPharmacyMedicineQuantity(int $pharmacyId, int $medicineId, int $quantityToAdd): Medicine
    {
        $pharmacy = Pharmacy::find($pharmacyId);
        if ($pharmacy) {
            $existingPivot = $pharmacy->medicines()->where('medicine_id', $medicineId)->first();
            if ($existingPivot) {
                $currentQuantity = $existingPivot->pivot->quantity ?? 0;
                $newQuantity = $currentQuantity + $quantityToAdd;
                $pharmacy->medicines()->updateExistingPivot($medicineId, ['quantity' => $newQuantity]);
            } else {
                $pharmacy->medicines()->syncWithoutDetaching([$medicineId => ['quantity' => $quantityToAdd]]);
            }
        }
        return Medicine::with('category')->find($medicineId);
    }

    public function updatePharmacyMedicineQuantity(int $pharmacyId, int $medicineId, int $quantity): void
    {
        $pharmacy = Pharmacy::find($pharmacyId);
        if ($pharmacy) {
            $pharmacy->medicines()->updateExistingPivot($medicineId, ['quantity' => $quantity]);
        }
    }

    public function removeMedicineFromPharmacy(int $pharmacyId, int $medicineId): void
    {
        $pharmacy = Pharmacy::find($pharmacyId);
        if ($pharmacy) {
            $pharmacy->medicines()->detach($medicineId);
        }
    }

    public function createOffer(array $data): Offer
    {
        return Offer::create($data);
    }

    public function updateOffer(Offer $offer, array $data): Offer
    {
        $offer->update($data);
        return $offer;
    }

    public function deleteOffer(Offer $offer): bool
    {
        return $offer->delete();
    }

    public function getOfferById(int $id)
    {
        return Offer::find($id);
    }

    public function getOwnerOffers(int $ownerId): Collection
    {
        return Offer::whereHas('pharmacy', function ($query) use ($ownerId) {
            $query->where('user_id', $ownerId);
        })->get();
    }

    public function findMedicineByNameAndCategory(string $name, int $categoryId): ?Medicine
    {
        return Medicine::where('name', $name)
            ->where('category_id', $categoryId)
            ->first();
    }

    public function findMedicineByBarcode(string $barcode): ?Medicine
    {
        return Medicine::where('barcode', $barcode)->first();
    }

    public function findMedicineByNameAndCategoryInPharmacy(string $name, int $categoryId, int $pharmacyId): ?Medicine
    {
        return Medicine::where('name', $name)
            ->where('category_id', $categoryId)
            ->whereHas('pharmacyMedicines', function ($query) use ($pharmacyId) {
                $query->where('pharmacy_id', $pharmacyId);
            })
            ->first();
    }

    public function findMedicineByBarcodeInPharmacy(string $barcode, int $pharmacyId): ?Medicine
    {
        return Medicine::where('barcode', $barcode)
            ->whereHas('pharmacyMedicines', function ($query) use ($pharmacyId) {
                $query->where('pharmacy_id', $pharmacyId);
            })
            ->first();
    }
}
