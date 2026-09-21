<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\ActivityLog;
use App\Models\Category;
use App\Models\Medicine;
use App\Models\Notification;
use App\Models\Offer;
use App\Models\Order;
use App\Models\Pharmacy;
use App\Models\Setting;
use App\Models\DashboardUser;
use App\Models\AppUser;
use App\Models\Package;
use App\Models\Country;
use App\Models\Governorate;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Storage;
use Illuminate\View\View;

class AdminController extends Controller
{
    public function locations(): View
    {
        return view('admin.locations', [
            'title' => 'Countries & governorates',
            'section' => 'locations',
            'countries' => Country::with('governorates')->orderBy('name_en')->get(),
        ]);
    }

    public function storeCountry(Request $request): RedirectResponse
    {
        $data = $request->validate([
            'name_ar' => ['required', 'string', 'max:255'],
            'name_en' => ['required', 'string', 'max:255'],
            'code' => ['required', 'string', 'size:2', 'alpha', 'unique:countries,code'],
        ]);
        $data['code'] = strtoupper($data['code']);
        Country::create($data);

        return back()->with('success', 'Country added successfully.');
    }

    public function updateCountry(Request $request, Country $country): RedirectResponse
    {
        $data = $request->validate([
            'name_ar' => ['required', 'string', 'max:255'],
            'name_en' => ['required', 'string', 'max:255'],
            'code' => ['required', 'string', 'size:2', 'alpha', 'unique:countries,code,'.$country->id],
        ]);
        $data['code'] = strtoupper($data['code']);
        $country->update($data);

        return back()->with('success', 'Country updated successfully.');
    }

    public function destroyCountry(Country $country): RedirectResponse
    {
        $country->delete();
        return back()->with('success', 'Country and its governorates deleted successfully.');
    }

    public function storeGovernorate(Request $request, Country $country): RedirectResponse
    {
        $data = $request->validate([
            'name_ar' => ['required', 'string', 'max:255'],
            'name_en' => ['required', 'string', 'max:255'],
        ]);
        $country->governorates()->create($data);

        return back()->with('success', 'Governorate added successfully.');
    }

    public function updateGovernorate(Request $request, Governorate $governorate): RedirectResponse
    {
        $data = $request->validate([
            'name_ar' => ['required', 'string', 'max:255'],
            'name_en' => ['required', 'string', 'max:255'],
        ]);
        $governorate->update($data);

        return back()->with('success', 'Governorate updated successfully.');
    }

    public function destroyGovernorate(Governorate $governorate): RedirectResponse
    {
        $governorate->delete();
        return back()->with('success', 'Governorate deleted successfully.');
    }

    public function dashboard(): View
    {
        $monthlyOrders = Order::selectRaw("DATE_FORMAT(created_at, '%b') as month, COUNT(*) as total")
            ->where('created_at', '>=', now()->subMonths(5)->startOfMonth())
            ->groupBy('month')->orderByRaw('MIN(created_at)')->get();

        return view('admin.dashboard', [
            'stats' => [
                'users' => AppUser::count(),
                'pharmacies' => Pharmacy::count(),
                'pending' => Pharmacy::where('status', 'pending')->count(),
                'orders' => Order::count(),
                'revenue' => Order::whereIn('status', ['accepted', 'preparing', 'ready', 'delivered'])->sum('total_price'),
            ],
            'pendingPharmacies' => Pharmacy::with('user')->where('status', 'pending')->latest()->take(5)->get(),
            'orderLabels' => $monthlyOrders->pluck('month'),
            'orderValues' => $monthlyOrders->pluck('total'),
            'orderStatuses' => Order::select('status', DB::raw('COUNT(*) as total'))->groupBy('status')->pluck('total', 'status'),
        ]);
    }

    public function pharmacies(Request $request): View
    {
        $query = Pharmacy::with('user')->latest();
        if ($request->filled('status')) $query->where('status', $request->string('status'));

        return view('admin.resource', [
            'title' => 'Pharmacy registration requests', 'section' => 'pharmacies',
            'description' => 'Review applications, verify submitted details, and keep the network trustworthy.',
            'items' => $query->paginate(12), 'statusFilter' => true,
        ]);
    }

    public function approvePharmacy(Pharmacy $pharmacy): RedirectResponse
    {
        $pharmacy->update(['status' => 'open']);
        $this->log('pharmacy.approved', $pharmacy, 'Pharmacy application approved.');
        return back()->with('success', __('admin.pharmacy_approved'));
    }

    public function rejectPharmacy(Pharmacy $pharmacy): RedirectResponse
    {
        $pharmacy->update(['status' => 'rejected']);
        $this->log('pharmacy.rejected', $pharmacy, 'Pharmacy application rejected.');
        return back()->with('success', __('admin.pharmacy_rejected'));
    }

    public function requestPharmacyInfo(Pharmacy $pharmacy): RedirectResponse
    {
        Notification::create(['user_id' => $pharmacy->user_id, 'pharmacy_id' => $pharmacy->id, 'type' => 'pharmacy.info_required', 'data' => json_encode(['message' => 'Please provide additional registration information.'])]);
        $this->log('pharmacy.info_requested', $pharmacy, 'Additional pharmacy information requested.');
        return back()->with('success', __('admin.info_requested'));
    }

    public function users(Request $request): View
    {
        $query = DashboardUser::latest();
        if ($request->filled('q')) {
            $query->where(function ($sub) use ($request) {
                $sub->where('name', 'like', '%'.$request->string('q').'%')
                    ->orWhere('email', 'like', '%'.$request->string('q').'%');
            });
        }

        return view('admin.resource', [
            'title' => 'User management',
            'section' => 'users',
            'description' => 'Manage customer, pharmacy owner, and administrator access.',
            'items' => $query->paginate(15)->withQueryString(),
            'roles' => ['admin', 'manager'],
            'search' => $request->string('q'),
        ]);
    }

    public function appUsers(Request $request): View
    {
        $query = AppUser::latest();
        if ($request->filled('q')) {
            $query->where(function ($sub) use ($request) {
                $sub->where('name', 'like', '%'.$request->string('q').'%')
                    ->orWhere('email', 'like', '%'.$request->string('q').'%');
            });
        }

        return view('admin.resource', [
            'title' => 'App user management',
            'section' => 'app-users',
            'description' => 'Manage customers and pharmacy owners using the mobile app.',
            'items' => $query->paginate(15)->withQueryString(),
            'search' => $request->string('q'),
        ]);
    }

    public function storeAppUser(Request $request): RedirectResponse
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'email', 'unique:app_users'],
            'password' => ['required', 'string', 'min:8'],
            'phone' => ['nullable', 'string', 'max:50'],
            'role' => ['required', 'in:customer,pharmacy_owner'],
        ]);
        $data['password'] = Hash::make($data['password']);
        AppUser::create($data);
        return back()->with('success', __('admin.app_user_created'));
    }

    public function updateAppUser(Request $request, AppUser $appUser): RedirectResponse
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'email', 'unique:app_users,email,'.$appUser->id],
            'phone' => ['nullable', 'string', 'max:50'],
            'role' => ['required', 'in:customer,pharmacy_owner'],
            'password' => ['nullable', 'string', 'min:8'],
        ]);
        if (!empty($data['password'])) $data['password'] = Hash::make($data['password']);
        else unset($data['password']);
        $appUser->update($data);
        return back()->with('success', __('admin.app_user_updated'));
    }

    public function toggleAppUser(AppUser $appUser): RedirectResponse
    {
        $appUser->update(['is_active' => !$appUser->is_active]);
        return back()->with('success', __('admin.app_user_status_updated'));
    }

    public function destroyAppUser(AppUser $appUser): RedirectResponse
    {
        $appUser->delete();
        return back()->with('success', __('admin.app_user_removed'));
    }

    public function editUser(DashboardUser $user): View
    {
        $query = DashboardUser::latest();
        return view('admin.resource', [
            'title' => 'User management',
            'section' => 'users',
            'description' => 'Manage customer, pharmacy owner, and administrator access.',
            'items' => $query->paginate(15)->withQueryString(),
            'roles' => ['admin', 'manager'],
            'editUser' => $user,
            'search' => request()->string('q'),
        ]);
    }

    public function storeUser(Request $request): RedirectResponse
    {
        $data = $request->validate(['name' => ['required', 'string', 'max:255'], 'email' => ['required', 'email', 'unique:dashboard_users'], 'password' => ['required', 'string', 'min:8'], 'role' => ['required', 'in:admin,manager']]);
        $data['password'] = Hash::make($data['password']); DashboardUser::create($data);
        return back()->with('success', __('admin.user_created'));
    }

    public function updateUser(Request $request, DashboardUser $user): RedirectResponse
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'email', 'unique:dashboard_users,email,'.$user->id],
            'role' => ['required', 'in:admin,manager'],
            'password' => ['nullable', 'string', 'min:8'],
        ]);

        if (!empty($data['password'])) {
            $data['password'] = Hash::make($data['password']);
        } else {
            unset($data['password']);
        }

        $user->update($data);

        return back()->with('success', __('admin.user_updated'));
    }

    public function destroyUser(DashboardUser $user): RedirectResponse
    {
        abort_if($user->is(Auth::user()), 422, 'You cannot remove your own account.');
        $user->delete(); return back()->with('success', __('admin.user_removed'));
    }

    public function categories(): View
    {
        return view('admin.resource', ['title' => 'Category management', 'section' => 'categories', 'description' => 'Organize the medicine catalogue for fast discovery.', 'items' => Category::withCount('medicines')->latest()->paginate(15)]);
    }

    public function storeCategory(Request $request): RedirectResponse
    {
        Category::create($request->validate(['name' => ['required', 'string', 'max:255'], 'description' => ['nullable', 'string']])); return back()->with('success', __('admin.category_created'));
    }

    public function updateCategory(Request $request, Category $category): RedirectResponse
    {
        $category->update($request->validate(['name' => ['required', 'string', 'max:255'], 'description' => ['nullable', 'string']])); return back()->with('success', __('admin.category_updated'));
    }

    public function destroyCategory(Category $category): RedirectResponse
    {
        abort_if($category->medicines()->exists(), 422, __('admin.remove_medicines_first')); $category->delete(); return back()->with('success', __('admin.category_removed'));
    }

    public function medicines(): View
    {
        return view('admin.resource', ['title' => 'Medicine management', 'section' => 'medicines', 'description' => 'Maintain the shared medicine catalogue and availability information.', 'items' => Medicine::with('category')->latest()->paginate(15), 'categories' => Category::orderBy('name')->get()]);
    }

    public function medicineCatalog(Request $request): View
    {
        $query = Medicine::with('category')->latest();

        if ($request->filled('q')) {
            $search = $request->string('q')->toString();
            $query->where(function ($builder) use ($search) {
                $builder->where('name', 'like', "%{$search}%")
                    ->orWhere('generic_name', 'like', "%{$search}%")
                    ->orWhere('barcode', 'like', "%{$search}%");
            });
        }
        if ($request->filled('category_id')) $query->where('category_id', $request->integer('category_id'));
        if ($request->filled('status')) $query->where('is_available', $request->string('status') === 'active');
        if ($request->filled('prescription')) $query->where('requires_prescription', $request->boolean('prescription'));

        return view('admin.medicine-catalog', [
            'items' => $query->paginate(15)->withQueryString(),
            'categories' => Category::orderBy('name')->get(),
            'title' => 'Medicine Catalog',
            'section' => 'medicine-catalog',
            'description' => 'Manage common medicines available as predefined templates for pharmacy owners.',
        ]);
    }

    public function storeCatalogMedicine(Request $request): RedirectResponse
    {
        $data = $this->validateCatalogMedicine($request);
        if ($request->hasFile('image')) {
            $data['image_path'] = Storage::url($request->file('image')->store('medicine_catalog', 'public'));
        }
        Medicine::create($data);
        return to_route('admin.medicine-catalog')->with('success', __('admin.catalog_created'));
    }

    public function updateCatalogMedicine(Request $request, Medicine $medicine): RedirectResponse
    {
        $data = $this->validateCatalogMedicine($request);
        if ($request->hasFile('image')) {
            $data['image_path'] = Storage::url($request->file('image')->store('medicine_catalog', 'public'));
        }
        $medicine->update($data);
        return to_route('admin.medicine-catalog', request()->only(['q', 'category_id', 'status', 'prescription']))->with('success', __('admin.catalog_updated'));
    }

    public function toggleCatalogMedicine(Medicine $medicine): RedirectResponse
    {
        $medicine->update(['is_available' => ! $medicine->is_available]);
        return back()->with('success', __('admin.catalog_status_updated'));
    }

    public function destroyCatalogMedicine(Medicine $medicine): RedirectResponse
    {
        abort_if($medicine->orderItems()->exists(), 422, 'This medicine has order history and cannot be deleted. Deactivate it instead.');
        $medicine->delete();
        return back()->with('success', __('admin.catalog_deleted'));
    }

    private function validateCatalogMedicine(Request $request): array
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'generic_name' => ['nullable', 'string', 'max:255'],
            'category_id' => ['required', 'exists:categories,id'],
            'description' => ['nullable', 'string'],
            'manufacturer' => ['nullable', 'string', 'max:255'],
            'dosage_form' => ['nullable', 'string', 'max:100'],
            'strength' => ['nullable', 'string', 'max:100'],
            'barcode' => ['nullable', 'string', 'max:255'],
            'requires_prescription' => ['sometimes', 'boolean'],
            'is_available' => ['sometimes', 'boolean'],
            'image' => ['nullable', 'image', 'mimes:jpeg,png,jpg,gif,webp', 'max:2048'],
        ]);
        $data['requires_prescription'] = $request->boolean('requires_prescription');
        $data['is_available'] = $request->boolean('is_available');
        return $data;
    }

    public function storeMedicine(Request $request): RedirectResponse
    {
        Medicine::create($request->validate(['category_id' => ['required', 'exists:categories,id'], 'name' => ['required', 'string', 'max:255'], 'description' => ['nullable', 'string'], 'price' => ['required', 'numeric', 'min:0'], 'discount_percentage' => ['required', 'integer', 'min:0', 'max:100'], 'quantity' => ['required', 'integer', 'min:0'], 'expiration_date' => ['nullable', 'date'], 'barcode' => ['nullable', 'string', 'max:255']])); return back()->with('success', 'Medicine created.');
    }

    public function updateMedicine(Request $request, Medicine $medicine): RedirectResponse
    {
        $medicine->update($request->validate(['category_id' => ['required', 'exists:categories,id'], 'name' => ['required', 'string', 'max:255'], 'description' => ['nullable', 'string'], 'price' => ['required', 'numeric', 'min:0'], 'discount_percentage' => ['required', 'integer', 'min:0', 'max:100'], 'quantity' => ['required', 'integer', 'min:0'], 'is_available' => ['sometimes', 'boolean'], 'expiration_date' => ['nullable', 'date'], 'barcode' => ['nullable', 'string', 'max:255']])); return back()->with('success', 'Medicine updated.');
    }

    public function destroyMedicine(Medicine $medicine): RedirectResponse
    {
        $medicine->delete(); return back()->with('success', __('admin.medicine_removed'));
    }

    public function offers(): View
    {
        return view('admin.resource', ['title' => 'Offer management', 'section' => 'offers', 'description' => 'Publish and maintain promotions across the pharmacy network.', 'items' => Offer::with('pharmacy')->latest()->paginate(15), 'pharmacies' => Pharmacy::where('status', 'open')->orderBy('name')->get()]);
    }

    public function packages(): View
    {
        return view('admin.packages', ['packages' => Package::orderBy('price')->get()]);
    }

    public function storePackage(Request $request): RedirectResponse
    {
        Package::create($request->validate([
            'name' => ['required', 'string', 'max:255'],
            'price' => ['required', 'numeric', 'min:0'],
            'duration_in_days' => ['required', 'integer', 'min:1'],
            'description' => ['nullable', 'string'],
        ]));
        return back()->with('success', 'Package created.');
    }

    public function updatePackage(Request $request, Package $package): RedirectResponse
    {
        $package->update($request->validate([
            'name' => ['required', 'string', 'max:255'],
            'price' => ['required', 'numeric', 'min:0'],
            'duration_in_days' => ['required', 'integer', 'min:1'],
            'description' => ['nullable', 'string'],
        ]));
        return back()->with('success', 'Package updated.');
    }

    public function togglePackage(Package $package): RedirectResponse
    {
        $package->update(['is_active' => !$package->is_active]);
        return back()->with('success', 'Package status updated.');
    }

    public function destroyPackage(Package $package): RedirectResponse
    {
        $package->delete();
        return back()->with('success', 'Package deleted.');
    }

    public function storeOffer(Request $request): RedirectResponse
    {
        Offer::create($request->validate(['pharmacy_id' => ['required', 'exists:pharmacies,id'], 'title' => ['required', 'string', 'max:255'], 'description' => ['nullable', 'string'], 'discount_percentage' => ['required', 'integer', 'min:0', 'max:100'], 'start_date' => ['required', 'date'], 'end_date' => ['required', 'date', 'after_or_equal:start_date']])); return back()->with('success', __('admin.offer_created'));
    }

    public function updateOffer(Request $request, Offer $offer): RedirectResponse
    {
        $offer->update($request->validate(['pharmacy_id' => ['required', 'exists:pharmacies,id'], 'title' => ['required', 'string', 'max:255'], 'description' => ['nullable', 'string'], 'discount_percentage' => ['required', 'integer', 'min:0', 'max:100'], 'start_date' => ['required', 'date'], 'end_date' => ['required', 'date', 'after_or_equal:start_date']])); return back()->with('success', __('admin.offer_updated'));
    }

    public function destroyOffer(Offer $offer): RedirectResponse
    {
        $offer->delete(); return back()->with('success', __('admin.offer_removed'));
    }

    public function orders(): View
    {
        return view('admin.resource', ['title' => 'Order management', 'section' => 'orders', 'description' => 'Monitor fulfilment across every pharmacy and resolve exceptions quickly.', 'items' => Order::with(['user', 'pharmacy'])->latest()->paginate(15)]);
    }

    public function updateOrderStatus(Request $request, Order $order): RedirectResponse
    {
        $order->update(['status' => $request->validate(['status' => ['required', 'in:pending,accepted,rejected,preparing,ready,delivered,cancelled']])['status']]); return back()->with('success', __('admin.order_status_updated'));
    }

    public function notifications(): View
    {
        return view('admin.resource', ['title' => 'Notifications management', 'section' => 'notifications', 'description' => 'Review system messages and requests delivered to users.', 'items' => Notification::with(['user', 'pharmacy'])->latest()->paginate(20)]);
    }

    public function activityLogs(): View
    {
        return view('admin.resource', ['title' => 'Activity logs', 'section' => 'activity-logs', 'description' => 'An operational history of important administrative actions.', 'items' => ActivityLog::with(['user', 'dashboardUser', 'pharmacy'])->latest()->paginate(25)]);
    }

    public function settings(): View
    {
        return view('admin.resource', ['title' => 'Application settings', 'section' => 'settings', 'description' => 'Control public contact details and the legal pages shown by the application.', 'settings' => Setting::firstOrCreate(['id' => 1], ['app_name' => config('app.name')])]);
    }

    public function updateSettings(Request $request): RedirectResponse
    {
        $data = $request->validate(['app_name' => ['required', 'string', 'max:255'], 'contact_email' => ['nullable', 'email'], 'contact_phone' => ['nullable', 'string', 'max:50'], 'contact_address' => ['nullable', 'string'], 'privacy_policy' => ['nullable', 'string'], 'terms_conditions' => ['nullable', 'string']]);
        Setting::updateOrCreate(['id' => 1], $data); return back()->with('success', __('admin.settings_saved'));
    }

    private function log(string $type, Pharmacy $pharmacy, string $message): void
    {
        ActivityLog::create(['dashboard_user_id' => Auth::id(), 'pharmacy_id' => $pharmacy->id, 'type' => $type, 'data' => json_encode(['message' => $message])]);
    }
}