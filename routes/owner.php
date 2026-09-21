<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Owner\PharmacyOwnerController;

Route::middleware(['jwt.auth'])->prefix('owner')->group(function () {
    Route::get('dashboard', [PharmacyOwnerController::class, 'dashboard']);
    Route::get('pharmacy', [PharmacyOwnerController::class, 'profile']);
    Route::put('pharmacy', [PharmacyOwnerController::class, 'updateProfile']);
    Route::put('pharmacy/emergency-close', [PharmacyOwnerController::class, 'updateEmergencyClose']);
    Route::put('pharmacy/status', [PharmacyOwnerController::class, 'updateStatus']);
    Route::put('pharmacy/hours', [PharmacyOwnerController::class, 'updateWorkingHours']);
    Route::post('pharmacy/images', [PharmacyOwnerController::class, 'uploadPharmacyImages']);

    Route::get('medicines', [PharmacyOwnerController::class, 'medicines']);
    Route::post('medicines', [PharmacyOwnerController::class, 'storeMedicine']);
    Route::get('medicines/{id}', [PharmacyOwnerController::class, 'showMedicine']);
    Route::put('medicines/{id}', [PharmacyOwnerController::class, 'updateMedicine']);
    Route::delete('medicines/{id}', [PharmacyOwnerController::class, 'deleteMedicine']);
    Route::patch('medicines/{id}/price', [PharmacyOwnerController::class, 'updateMedicinePrice']);
    Route::patch('medicines/{id}/quantity', [PharmacyOwnerController::class, 'updateMedicineQuantity']);
    Route::patch('medicines/{id}/availability', [PharmacyOwnerController::class, 'updateMedicineAvailability']);
    Route::post('medicines/{id}/image', [PharmacyOwnerController::class, 'uploadMedicineImage']);

    Route::get('offers', [PharmacyOwnerController::class, 'offers']);
    Route::post('offers', [PharmacyOwnerController::class, 'storeOffer']);
    Route::get('offers/{id}', [PharmacyOwnerController::class, 'showOffer']);
    Route::put('offers/{id}', [PharmacyOwnerController::class, 'updateOffer']);
    Route::delete('offers/{id}', [PharmacyOwnerController::class, 'deleteOffer']);
    Route::post('offers/{id}/image', [PharmacyOwnerController::class, 'uploadOfferImage']);
});
