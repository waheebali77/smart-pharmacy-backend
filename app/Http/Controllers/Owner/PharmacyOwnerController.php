<?php

namespace App\Http\Controllers\Owner;

use App\Http\Controllers\Controller;
use App\Http\Requests\Owner\UpdatePharmacyRequest;
use App\Http\Requests\Owner\UpdatePharmacyStatusRequest;
use App\Http\Requests\Owner\UpdateEmergencyCloseRequest;
use App\Http\Requests\Owner\UpdateWorkingHoursRequest;
use App\Http\Requests\Owner\UploadPharmacyImagesRequest;
use App\Http\Requests\Owner\StoreMedicineRequest;
use App\Http\Requests\Owner\UpdateMedicineRequest;
use App\Http\Requests\Owner\UpdateMedicinePriceRequest;
use App\Http\Requests\Owner\UpdateMedicineQuantityRequest;
use App\Http\Requests\Owner\UpdateMedicineAvailabilityRequest;
use App\Http\Requests\Owner\UploadMedicineImageRequest;
use App\Http\Requests\Owner\StoreOfferRequest;
use App\Http\Requests\Owner\UpdateOfferRequest;
use App\Http\Requests\Owner\UploadOfferImageRequest;
use App\Services\Owner\PharmacyOwnerService;
use App\Models\Medicine;
use App\Models\Offer;
use App\Models\Pharmacy;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class PharmacyOwnerController extends Controller
{
    protected PharmacyOwnerService $service;

    public function __construct(PharmacyOwnerService $service)
    {
        $this->service = $service;
    }

    public function dashboard()
    {
        return $this->service->dashboard();
    }

    public function profile()
    {
        return $this->service->getPharmacyProfile();
    }

    public function updateProfile(UpdatePharmacyRequest $request)
    {
        $data = $request->validated();

        if (array_key_exists('is_manually_closed', $data)) {
            $data['manual_status'] = $data['is_manually_closed'] ? 'closed' : 'open';
        }

        $pharmacy = $this->service->updatePharmacyProfile($data);

        return response()->json([
            'success' => true,
            'message' => 'Pharmacy profile updated successfully',
            'data' => $pharmacy,
        ]);
    }

    public function updateEmergencyClose(UpdateEmergencyCloseRequest $request)
    {
        return $this->service->setEmergencyClose(
            $request->validated()['is_manually_closed']
        );
    }

    public function updateStatus(UpdatePharmacyStatusRequest $request)
    {
        $pharmacy = $this->service->getPharmacyProfile()->resource;
        return $this->service->setPharmacyStatus($pharmacy, $request->validated()['status']);
    }

    public function updateWorkingHours(UpdateWorkingHoursRequest $request)
    {
        return $this->service->updatePharmacyProfile($request->validated());
    }

    public function uploadPharmacyImages(UploadPharmacyImagesRequest $request)
    {
        $pharmacy = $this->service->getPharmacyProfile()->resource;
        $images = $pharmacy->images ?? [];

        foreach ($request->file('images') as $image) {
            $path = $image->store('pharmacy_images', 'public');
            $images[] = Storage::url($path);
        }

        $updated = $this->service->updatePharmacyProfile(['images' => $images]);
        return $updated;
    }

    public function medicines()
    {
        return $this->service->getOwnerMedicines();
    }

    public function catalogMedicines(\Illuminate\Http\Request $request)
    {
        return $this->service->searchCatalogMedicines($request->string('search')->toString());
    }

    public function addCatalogMedicine(int $id, \Illuminate\Http\Request $request)
    {
        $data = $request->validate([
            'price' => ['required', 'numeric', 'min:0'],
            'discount_percentage' => ['sometimes', 'integer', 'min:0', 'max:100'],
            'quantity' => ['required', 'integer', 'min:0'],
            'expiration_date' => ['nullable', 'date'],
            'barcode' => ['nullable', 'string', 'max:100'],
            'is_available' => ['sometimes', 'boolean'],
            'is_donation' => ['sometimes', 'boolean'],
            'is_near_expiry' => ['sometimes', 'boolean'],
        ]);
        return $this->service->addCatalogMedicine($id, $data);
    }

    public function storeMedicine(StoreMedicineRequest $request)
    {
        $data = $request->validated();

        if ($request->hasFile('image')) {
            $data['image_path'] = Storage::url($request->file('image')->store('medicine_images', 'public'));
        }

        $result = $this->service->createMedicine($data);

        // If medicine exists, return with notification
        if (isset($result['exists']) && $result['exists'] === true) {
            return response()->json($result, 409); // 409 Conflict status
        }

        return response()->json($result, 201); // 201 Created status
    }

    public function showMedicine(int $id)
    {
        return $this->service->getMedicineById($id);
    }

    public function updateMedicine(int $id, UpdateMedicineRequest $request)
    {
        $medicine = Medicine::findOrFail($id);
        $data = $request->validated();

        if ($request->hasFile('image')) {
            $data['image_path'] = Storage::url($request->file('image')->store('medicine_images', 'public'));
        }

        return $this->service->updateMedicine($medicine, $data);
    }

    public function deleteMedicine(int $id)
    {
        $medicine = Medicine::findOrFail($id);
        $this->service->deleteMedicine($medicine);
        return response()->json(['message' => 'Medicine deleted successfully']);
    }

    public function updateMedicinePrice(int $id, UpdateMedicinePriceRequest $request)
    {
        $medicine = Medicine::findOrFail($id);
        return $this->service->updateMedicinePrice($medicine, $request->validated()['price']);
    }

    public function updateMedicineQuantity(int $id, UpdateMedicineQuantityRequest $request)
    {
        $medicine = Medicine::findOrFail($id);
        return $this->service->updateMedicineQuantity($medicine, $request->validated()['quantity']);
    }

    public function updateMedicineAvailability(int $id, UpdateMedicineAvailabilityRequest $request)
    {
        $medicine = Medicine::findOrFail($id);
        return $this->service->updateMedicineAvailability($medicine, $request->validated()['is_available']);
    }

    public function offers()
    {
        return $this->service->getOwnerOffers();
    }

    public function storeOffer(StoreOfferRequest $request)
    {
        $data = $request->validated();

        if ($request->hasFile('image')) {
            $data['image_path'] = Storage::url($request->file('image')->store('offer_images', 'public'));
        }

        $pharmacy = $this->service->getPharmacyProfile()->resource;
        $data['pharmacy_id'] = $pharmacy->id;

        return $this->service->createOffer($data);
    }

    public function showOffer(int $id)
    {
        return $this->service->getOfferById($id);
    }

    public function updateOffer(int $id, UpdateOfferRequest $request)
    {
        $offer = Offer::findOrFail($id);
        $data = $request->validated();

        if ($request->hasFile('image')) {
            $data['image_path'] = Storage::url($request->file('image')->store('offer_images', 'public'));
        }

        return $this->service->updateOffer($offer, $data);
    }

    public function deleteOffer(int $id)
    {
        $offer = Offer::findOrFail($id);
        $this->service->deleteOffer($offer);
        return response()->json(['message' => 'Offer deleted successfully']);
    }

    public function uploadOfferImage(int $id, UploadOfferImageRequest $request)
    {
        $offer = Offer::findOrFail($id);
        $path = Storage::url($request->file('image')->store('offer_images', 'public'));
        return $this->service->updateOffer($offer, ['image_path' => $path]);
    }
}
