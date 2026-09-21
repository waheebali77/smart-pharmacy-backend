<?php

namespace App\Http\Controllers;

use App\Models\Medicine;
use App\Models\Offer;
use App\Models\Order;
use App\Models\OrderItem;
use App\Models\Notification;
use App\Models\ActivityLog;
use App\Models\Pharmacy;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;

class ShopController extends Controller
{
    public function home()
    {
        // Get featured offers
        $offers = Offer::with('pharmacy')
            ->whereDate('end_date', '>=', now())
            ->orderBy('start_date', 'desc')
            ->take(5)
            ->get();
            
        // Get nearby pharmacies (mock data for now, in a real app this would use geolocation)
        $pharmacies = Pharmacy::select('*')
            ->addSelect(DB::raw('6371 * acos(cos(radians(?)) * cos(radians(latitude)) * cos(radians(longitude) - radians(?)) + sin(radians(?)) * sin(radians(latitude))) AS distance'))
            ->setBindings([30.0444, 31.2357, 30.0444]) // Cairo coordinates as example
            ->having('distance', '<', 10) // Within 10km
            ->orderBy('distance')
            ->take(6)
            ->get();
            
        // Get all categories
        $categories = \App\Models\Category::all();
        
        // Get popular medicines (medicines with most orders)
        $popularMedicineIds = DB::table('order_items')
            ->select('medicine_id')
            ->groupBy('medicine_id')
            ->orderByRaw('COUNT(*) DESC')
            ->limit(6)
            ->pluck('medicine_id');
            
        $medicines = Medicine::whereIn('id', $popularMedicineIds)
            ->with('category')
            ->get();
            
        return view('shop.home', compact('offers', 'pharmacies', 'categories', 'medicines'));
    }
    
    public function offers()
    {
        $offers = Offer::with('pharmacy')
            ->whereDate('end_date', '>=', now())
            ->orderBy('start_date', 'desc')
            ->paginate(12);

        return view('shop.offers', compact('offers'));
    }

    public function medicines(Request $request)
    {
        $query = Medicine::query()->with('category');
        if ($request->filled('pharmacy')) {
            $pharmacyId = $request->integer('pharmacy');
            $query->whereHas('pharmacyMedicines', function ($q) use ($pharmacyId) {
                $q->where('pharmacy_medicines.pharmacy_id', $pharmacyId)
                  ->where('pharmacy_medicines.quantity', '>', 0)
                  ->where('pharmacy_medicines.is_available', true);
            });
        }

        $medicines = $query->where('is_available', true)
            ->whereHas('pharmacyMedicines', function ($q) {
                $q->where('pharmacies.status', 'open')
                  ->where('pharmacy_medicines.quantity', '>', 0)
                  ->where('pharmacy_medicines.is_available', true);
            })
            ->latest()
            ->paginate(18)
            ->withQueryString();

        return view('shop.medicines', compact('medicines'));
    }

    public function addToCart(Request $request)
    {
        $data = $request->validate(['medicine_id' => 'required|exists:medicines,id', 'quantity' => 'sometimes|integer|min:1']);
        $qty = $request->integer('quantity', 1);
        $medicine = Medicine::findOrFail($data['medicine_id']);

        // determine pharmacy for this medicine (first that has stock)
        $pivot = $medicine->pharmacyMedicines()->where('pharmacies.status', 'open')->wherePivot('quantity', '>', 0)->wherePivot('is_available', true)->first();
        if (!$pivot) return back()->with('error', 'This item is not available from any pharmacy.');

        $pharmacyId = $pivot->id;

        $cart = session()->get('cart', []);
        // enforce single-pharmacy cart
        if (!empty($cart) && isset($cart['pharmacy_id']) && $cart['pharmacy_id'] !== $pharmacyId) {
            return back()->with('error', 'Your cart contains items from another pharmacy. Please clear the cart first.');
        }

        $cart['pharmacy_id'] = $pharmacyId;
        $items = $cart['items'] ?? [];
        if (isset($items[$medicine->id])) {
            $items[$medicine->id]['quantity'] += $qty;
        } else {
            $items[$medicine->id] = [
                'medicine_id' => $medicine->id,
                'name' => $medicine->name,
                'price' => $medicine->price,
                'quantity' => $qty,
            ];
        }

        $cart['items'] = $items;
        session(['cart' => $cart]);

        return back()->with('success', 'Item added to cart.');
    }

    public function cart()
    {
        $cart = session()->get('cart', ['items' => []]);
        return view('shop.cart', compact('cart'));
    }

    public function checkout()
    {
        if (!Auth::check()) return redirect()->route('login');
        $cart = session()->get('cart', ['items' => []]);
        if (empty($cart['items'] ?? [])) return redirect()->route('medicines.index')->with('error', 'Your cart is empty.');
        return view('shop.checkout', compact('cart'));
    }

    public function placeOrder(Request $request)
    {
        if (!Auth::check()) return redirect()->route('login');
        $cart = session()->get('cart', null);
        if (empty($cart) || empty($cart['items'])) return back()->with('error', 'No items in cart.');

        $data = $request->validate(['address' => ['required', 'string', 'max:1024']]);

        $total = 0;
        foreach ($cart['items'] as $it) {
            $total += ($it['price'] * $it['quantity']);
        }

        $order = Order::create(['user_id' => Auth::id(), 'pharmacy_id' => $cart['pharmacy_id'], 'status' => 'pending', 'total_price' => $total]);

        foreach ($cart['items'] as $it) {
            OrderItem::create(['order_id' => $order->id, 'medicine_id' => $it['medicine_id'], 'quantity' => $it['quantity'], 'price' => $it['price']]);
        }

        session()->forget('cart');

        return redirect()->route('medicines.index')->with('success', 'Order placed successfully.');
    }

    public function search(Request $request)
    {
        $q = $request->string('q');
        $medicines = collect();
        $offers = collect();
        $pharmacies = collect();

        if ($q) {
            $medicines = Medicine::where('name', 'like', "%{$q}%")->orWhere('description', 'like', "%{$q}%")->limit(50)->get();
            $offers = Offer::where('title', 'like', "%{$q}%")->orWhere('description', 'like', "%{$q}%")->limit(50)->get();
            $pharmacies = \App\Models\Pharmacy::where('name', 'like', "%{$q}%")->orWhere('address', 'like', "%{$q}%")->limit(50)->get();
        }

        return view('shop.search', compact('q', 'medicines', 'offers', 'pharmacies'));
    }

    public function medicineDetails(Medicine $medicine)
    {
        $pivot = $medicine->pharmacyMedicines()->wherePivot('quantity', '>', 0)->first();
        $available = (bool) $pivot;
        $pharmacy = $pivot ? \App\Models\Pharmacy::find($pivot->id) : null;
        return view('shop.medicine', compact('medicine', 'available', 'pharmacy'));
    }

    public function offerDetails(Offer $offer)
    {
        $pharmacy = $offer->pharmacy;
        return view('shop.offer', compact('offer', 'pharmacy'));
    }

    public function requestItem(Request $request)
    {
        $data = $request->validate(['type' => 'required|string', 'id' => 'required|integer']);
        if (!Auth::check()) return redirect()->route('login');

        $userId = Auth::id();

        if ($data['type'] === 'medicine') {
            $medicine = Medicine::findOrFail($data['id']);
            $pivot = $medicine->pharmacyMedicines()->wherePivot('quantity', '>', 0)->first();
            $pharmacyId = $pivot ? $pivot->id : null;
            $total = $medicine->price;
            $order = Order::create(['user_id' => $userId, 'pharmacy_id' => $pharmacyId ?? 0, 'status' => 'pending', 'total_price' => $total]);
            OrderItem::create(['order_id' => $order->id, 'medicine_id' => $medicine->id, 'quantity' => 1, 'price' => $medicine->price]);
            // notify owner
            if ($pharmacyId) {
                $ownerId = optional(Pharmacy::find($pharmacyId))->user_id;
                if ($ownerId) {
                    Notification::create(['user_id' => $ownerId, 'pharmacy_id' => $pharmacyId, 'type' => 'order.requested', 'data' => json_encode(['order_id' => $order->id, 'message' => 'A customer requested a medicine.'])]);
                    ActivityLog::create(['user_id' => $userId, 'pharmacy_id' => $pharmacyId, 'type' => 'order.requested', 'data' => json_encode(['order_id' => $order->id])]);
                }
            }
        } elseif ($data['type'] === 'offer') {
            $offer = Offer::findOrFail($data['id']);
            $order = Order::create(['user_id' => $userId, 'pharmacy_id' => $offer->pharmacy_id, 'status' => 'pending', 'total_price' => 0]);
            // notify owner
            $ownerId = optional($offer->pharmacy)->user_id;
            if ($ownerId) {
                Notification::create(['user_id' => $ownerId, 'pharmacy_id' => $offer->pharmacy_id, 'type' => 'order.requested', 'data' => json_encode(['order_id' => $order->id, 'message' => 'A customer requested an offer.'])]);
                ActivityLog::create(['user_id' => $userId, 'pharmacy_id' => $offer->pharmacy_id, 'type' => 'order.requested', 'data' => json_encode(['order_id' => $order->id])]);
            }
        } elseif ($data['type'] === 'pharmacy') {
            $pharmacy = \App\Models\Pharmacy::findOrFail($data['id']);
            $order = Order::create(['user_id' => $userId, 'pharmacy_id' => $pharmacy->id, 'status' => 'pending', 'total_price' => 0]);
            $ownerId = $pharmacy->user_id;
            if ($ownerId) {
                Notification::create(['user_id' => $ownerId, 'pharmacy_id' => $pharmacy->id, 'type' => 'order.requested', 'data' => json_encode(['order_id' => $order->id, 'message' => 'A customer requested a pharmacy.'])]);
                ActivityLog::create(['user_id' => $userId, 'pharmacy_id' => $pharmacy->id, 'type' => 'order.requested', 'data' => json_encode(['order_id' => $order->id])]);
            }
        } else {
            return back()->with('error', 'Unknown request type.');
        }

        return redirect()->route('shop.orders')->with('success', 'Request created. You will find it in your orders.');
    }

    public function orders()
    {
        if (!Auth::check()) return redirect()->route('login');
        $items = Order::with('items.medicine')->where('user_id', Auth::id())->latest()->paginate(12);
        return view('shop.orders', compact('items'));
    }
}
