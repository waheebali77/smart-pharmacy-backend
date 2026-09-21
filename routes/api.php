<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Auth\AuthController;
use App\Http\Controllers\Customer\CustomerController;
use App\Http\Controllers\Customer\NotificationController;
use App\Http\Controllers\Customer\ActivityLogController;
use App\Http\Controllers\Customer\OrderController as CustomerOrderController;
// use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Owner\PharmacyOwnerController;
use App\Http\Controllers\Owner\OrderController as OwnerOrderController;
use App\Http\Controllers\PackageController;
use App\Http\Controllers\OfferController;
use App\Http\Controllers\LocationController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| is assigned the "api" middleware group. Enjoy building your API!
|
*/

Route::get('health', function () {
    return response()->json([
        'status' => 'ok',
        'message' => 'API is working',
    ]);
});

Route::prefix('auth')->group(function () {
    // Public routes
    Route::post('register/customer', [AuthController::class, 'registerCustomer']);
    Route::post('register/pharmacy-owner', [AuthController::class, 'registerPharmacyOwner']);
    Route::post('login', [AuthController::class, 'login']);
    Route::post('forgot-password', [AuthController::class, 'forgotPassword']);
    Route::post('reset-password', [AuthController::class, 'resetPassword']);
    Route::post('request-otp-reset', [AuthController::class, 'requestOtpReset']);
    Route::post('verify-otp-reset', [AuthController::class, 'verifyOtpReset']);
    Route::post('reset-password-phone', [AuthController::class, 'resetPasswordPhone']);

    // Protected routes
    Route::middleware(['auth:api', 'pharmacy.subscription'])->group(function () {
        Route::post('logout', [AuthController::class, 'logout']);
        Route::delete('profile', [AuthController::class, 'deleteAccount']);
        Route::post('refresh', [AuthController::class, 'refresh']);
        Route::get('profile', [AuthController::class, 'profile']);
        Route::put('profile', [AuthController::class, 'updateProfile']);
        Route::post('profile/avatar', [AuthController::class, 'uploadAvatar']);
        Route::put('change-password', [AuthController::class, 'changePassword']);
    });
});

// Public catalogue search used before a customer places an order.
Route::get('/customer/medicines/search', [CustomerController::class, 'searchMedicines']);
Route::get('/customer/offers/featured', [CustomerController::class, 'featuredOffers']);
Route::get('/packages', [PackageController::class, 'index']);
Route::get('/offers', [OfferController::class, 'index']);

// Locations are read by the app during onboarding.
Route::get('/locations', [LocationController::class, 'index']);

// Location management is restricted to administrator accounts.
Route::middleware(['auth:api', 'admin'])->prefix('admin/locations')->group(function () {
    Route::post('countries', [LocationController::class, 'storeCountry']);
    Route::post('countries/{country}/governorates', [LocationController::class, 'storeGovernorate']);
    Route::patch('countries/{country}', [LocationController::class, 'updateCountry']);
    Route::delete('countries/{country}', [LocationController::class, 'destroyCountry']);
    Route::patch('governorates/{governorate}', [LocationController::class, 'updateGovernorate']);
    Route::delete('governorates/{governorate}', [LocationController::class, 'destroyGovernorate']);
});

/*
|--------------------------------------------------------------------------
| Customer APIs
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for customer endpoints.
| These routes are protected by JWT authentication.
|
*/

Route::middleware(['auth:api', 'pharmacy.subscription'])->group(function () {
    Route::get('/customer/home', [CustomerController::class, 'home']);
    Route::get('/customer/pharmacies/nearby', [CustomerController::class, 'nearbyPharmacies']);
    Route::get('/customer/pharmacies', [CustomerController::class, 'allPharmacies']);
    Route::get('/customer/pharmacies/{id}/medicines', [CustomerController::class, 'pharmacyMedicines']);
    Route::get('/customer/pharmacies/{id}', [CustomerController::class, 'pharmacyDetails']);
    Route::get('/customer/categories', [CustomerController::class, 'categories']);
    Route::get('/customer/medicines/popular', [CustomerController::class, 'popularMedicines']);
    Route::get('/customer/medicines/{id}/availability', [CustomerController::class, 'medicineAvailability']);

    Route::prefix('customer')->group(function () {
        Route::get('orders', [CustomerOrderController::class, 'index']);
        Route::post('orders', [CustomerOrderController::class, 'store']);
        Route::get('orders/{id}', [CustomerOrderController::class, 'show']);
        Route::delete('orders/{id}', [CustomerOrderController::class, 'destroy']);
        Route::patch('orders/{id}/cancel', [CustomerOrderController::class, 'cancel']);
        Route::post('medicines/{id}/request', [CustomerController::class, 'requestMedicine']);
        Route::post('offers/{id}/request', [CustomerController::class, 'requestOffer']);
    });

    Route::get('notifications', [NotificationController::class, 'index']);
    Route::patch('notifications/{id}/read', [NotificationController::class, 'markAsRead']);
    Route::get('activity-logs', [ActivityLogController::class, 'index']);

    Route::prefix('owner')->group(function () {
        Route::get('dashboard', [PharmacyOwnerController::class, 'dashboard']);
        Route::get('orders', [OwnerOrderController::class, 'index']);
        Route::get('orders/{id}', [OwnerOrderController::class, 'show']);
        Route::patch('orders/{id}/accept', [OwnerOrderController::class, 'accept']);
        Route::patch('orders/{id}/reject', [OwnerOrderController::class, 'reject']);
        Route::patch('orders/{id}/preparing', [OwnerOrderController::class, 'preparing']);
        Route::patch('orders/{id}/ready', [OwnerOrderController::class, 'ready']);
        Route::patch('orders/{id}/delivered', [OwnerOrderController::class, 'delivered']);
        Route::get('pharmacy', [PharmacyOwnerController::class, 'profile']);
        Route::put('pharmacy', [PharmacyOwnerController::class, 'updateProfile']);
        Route::put('pharmacy/emergency-close', [PharmacyOwnerController::class, 'updateEmergencyClose']);
        Route::put('pharmacy/status', [PharmacyOwnerController::class, 'updateStatus']);
        Route::put('pharmacy/hours', [PharmacyOwnerController::class, 'updateWorkingHours']);
        Route::post('pharmacy/images', [PharmacyOwnerController::class, 'uploadPharmacyImages']);

        Route::get('medicines', [PharmacyOwnerController::class, 'medicines']);
        Route::get('medicines/catalog', [PharmacyOwnerController::class, 'catalogMedicines']);
        Route::post('medicines/{id}/inventory', [PharmacyOwnerController::class, 'addCatalogMedicine']);
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
});