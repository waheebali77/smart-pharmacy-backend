<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Admin\AdminAuthController;
use App\Http\Controllers\Admin\AdminController;
use App\Http\Controllers\ShopController;

Route::get('/login', function () {
    return redirect()->route('admin.login');
})->name('login');

Route::get('/reset-password/{token}', function (string $token) {
    return response()->json([
        'message' => 'Open the Smart Pharmacy app to complete your password reset.',
    ]);
})->name('password.reset');

Route::get('/admin/login', [AdminAuthController::class, 'create'])->name('admin.login');
Route::post('/admin/login', [AdminAuthController::class, 'store'])->name('admin.login.store');
Route::post('/admin/logout', [AdminAuthController::class, 'destroy'])->middleware('auth')->name('admin.logout');
Route::post('/admin/language', function (\Illuminate\Http\Request $request) {
    $locale = $request->input('locale');
    abort_unless(in_array($locale, ['en', 'ar'], true), 400);
    $request->session()->put('locale', $locale);
    return back();
})->middleware('auth')->name('admin.language');

Route::prefix('admin')->name('admin.')->middleware(['auth', 'admin'])->group(function () {
    Route::get('/', [AdminController::class, 'dashboard'])->name('dashboard');
    Route::get('/pharmacies', [AdminController::class, 'pharmacies'])->name('pharmacies');
    Route::patch('/pharmacies/{pharmacy}/approve', [AdminController::class, 'approvePharmacy'])->name('pharmacies.approve');
    Route::patch('/pharmacies/{pharmacy}/reject', [AdminController::class, 'rejectPharmacy'])->name('pharmacies.reject');
    Route::patch('/pharmacies/{pharmacy}/request-info', [AdminController::class, 'requestPharmacyInfo'])->name('pharmacies.request-info');
    Route::get('/users', [AdminController::class, 'users'])->name('users');
    Route::get('/app-users', [AdminController::class, 'appUsers'])->name('app-users');
    Route::post('/app-users', [AdminController::class, 'storeAppUser'])->name('app-users.store');
    Route::patch('/app-users/{appUser}', [AdminController::class, 'updateAppUser'])->name('app-users.update');
    Route::patch('/app-users/{appUser}/status', [AdminController::class, 'toggleAppUser'])->name('app-users.status');
    Route::delete('/app-users/{appUser}', [AdminController::class, 'destroyAppUser'])->name('app-users.destroy');
    Route::get('/users/{user}/edit', [AdminController::class, 'editUser'])->name('users.edit');
    Route::post('/users', [AdminController::class, 'storeUser'])->name('users.store');
    Route::patch('/users/{user}', [AdminController::class, 'updateUser'])->name('users.update');
    Route::delete('/users/{user}', [AdminController::class, 'destroyUser'])->name('users.destroy');
    Route::get('/categories', [AdminController::class, 'categories'])->name('categories');
    Route::post('/categories', [AdminController::class, 'storeCategory'])->name('categories.store');
    Route::patch('/categories/{category}', [AdminController::class, 'updateCategory'])->name('categories.update');
    Route::delete('/categories/{category}', [AdminController::class, 'destroyCategory'])->name('categories.destroy');
    Route::get('/medicines', [AdminController::class, 'medicines'])->name('medicines');
    Route::post('/medicines', [AdminController::class, 'storeMedicine'])->name('medicines.store');
    Route::patch('/medicines/{medicine}', [AdminController::class, 'updateMedicine'])->name('medicines.update');
    Route::delete('/medicines/{medicine}', [AdminController::class, 'destroyMedicine'])->name('medicines.destroy');
    Route::get('/medicine-catalog', [AdminController::class, 'medicineCatalog'])->name('medicine-catalog');
    Route::get('/packages', [AdminController::class, 'packages'])->name('packages');
    Route::post('/packages', [AdminController::class, 'storePackage'])->name('packages.store');
    Route::patch('/packages/{package}', [AdminController::class, 'updatePackage'])->name('packages.update');
    Route::patch('/packages/{package}', [AdminController::class, 'updatePackage'])->name('packages.update');
    Route::patch('/packages/{package}/status', [AdminController::class, 'togglePackage'])->name('packages.status');
    Route::delete('/packages/{package}', [AdminController::class, 'destroyPackage'])->name('packages.destroy');
    Route::post('/medicine-catalog', [AdminController::class, 'storeCatalogMedicine'])->name('medicine-catalog.store');
    Route::patch('/medicine-catalog/{medicine}', [AdminController::class, 'updateCatalogMedicine'])->name('medicine-catalog.update');
    Route::patch('/medicine-catalog/{medicine}/status', [AdminController::class, 'toggleCatalogMedicine'])->name('medicine-catalog.status');
    Route::delete('/medicine-catalog/{medicine}', [AdminController::class, 'destroyCatalogMedicine'])->name('medicine-catalog.destroy');
    Route::get('/offers', [AdminController::class, 'offers'])->name('offers');
    Route::post('/offers', [AdminController::class, 'storeOffer'])->name('offers.store');
    Route::patch('/offers/{offer}', [AdminController::class, 'updateOffer'])->name('offers.update');
    Route::delete('/offers/{offer}', [AdminController::class, 'destroyOffer'])->name('offers.destroy');
    Route::get('/orders', [AdminController::class, 'orders'])->name('orders');
    Route::patch('/orders/{order}/status', [AdminController::class, 'updateOrderStatus'])->name('orders.status');
    Route::get('/notifications', [AdminController::class, 'notifications'])->name('notifications');
    Route::get('/activity-logs', [AdminController::class, 'activityLogs'])->name('activity-logs');
    Route::get('/settings', [AdminController::class, 'settings'])->name('settings');
    Route::put('/settings', [AdminController::class, 'updateSettings'])->name('settings.update');
    Route::get('/locations', [AdminController::class, 'locations'])->name('locations');
    Route::post('/locations/countries', [AdminController::class, 'storeCountry'])->name('locations.countries.store');
    Route::put('/locations/countries/{country}', [AdminController::class, 'updateCountry'])->name('locations.countries.update');
    Route::delete('/locations/countries/{country}', [AdminController::class, 'destroyCountry'])->name('locations.countries.destroy');
    Route::post('/locations/countries/{country}/governorates', [AdminController::class, 'storeGovernorate'])->name('locations.governorates.store');
    Route::put('/locations/governorates/{governorate}', [AdminController::class, 'updateGovernorate'])->name('locations.governorates.update');
    Route::delete('/locations/governorates/{governorate}', [AdminController::class, 'destroyGovernorate'])->name('locations.governorates.destroy');
});

// Public shop routes
Route::get('/', [ShopController::class, 'home'])->name('shop.home');
Route::get('/offers', [ShopController::class, 'offers'])->name('offers.index');
Route::get('/medicines', [ShopController::class, 'medicines'])->name('medicines.index');
Route::get('/medicines/{medicine}', [ShopController::class, 'medicineDetails'])->name('medicines.show');
Route::get('/offers/{offer}', [ShopController::class, 'offerDetails'])->name('offers.show');
Route::post('/cart/add', [ShopController::class, 'addToCart'])->name('cart.add');
Route::get('/cart', [ShopController::class, 'cart'])->name('cart.index');
Route::get('/checkout', [ShopController::class, 'checkout'])->name('checkout.index');
Route::post('/checkout', [ShopController::class, 'placeOrder'])->name('checkout.place');
Route::get('/search', [ShopController::class, 'search'])->name('shop.search');
Route::post('/request-item', [ShopController::class, 'requestItem'])->name('shop.request');
Route::get('/my-orders', [ShopController::class, 'orders'])->name('shop.orders');
