<?php

namespace App\Http\Controllers\Owner;

use App\Http\Controllers\Controller;
use App\Http\Requests\Owner\OrderActionRequest;
use App\Services\OrderService;
use Illuminate\Support\Facades\Auth;

class OrderController extends Controller
{
    protected OrderService $orderService;

    public function __construct(OrderService $orderService)
    {
        $this->orderService = $orderService;
    }

    public function index()
    {
        return $this->orderService->getPharmacyOrders(Auth::id());
    }

    public function show(int $id)
    {
        return $this->orderService->getPharmacyOrder(Auth::id(), $id);
    }

    public function accept(int $id, OrderActionRequest $request)
    {
        return $this->orderService->updateOrderStatusByOwner(Auth::id(), $id, 'accepted');
    }

    public function reject(int $id, OrderActionRequest $request)
    {
        return $this->orderService->updateOrderStatusByOwner(Auth::id(), $id, 'rejected');
    }

    public function preparing(int $id, OrderActionRequest $request)
    {
        return $this->orderService->updateOrderStatusByOwner(Auth::id(), $id, 'preparing');
    }

    public function ready(int $id, OrderActionRequest $request)
    {
        return $this->orderService->updateOrderStatusByOwner(Auth::id(), $id, 'ready');
    }

    public function delivered(int $id, OrderActionRequest $request)
    {
        return $this->orderService->updateOrderStatusByOwner(Auth::id(), $id, 'delivered');
    }
}
