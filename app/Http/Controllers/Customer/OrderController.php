<?php

namespace App\Http\Controllers\Customer;

use App\Http\Controllers\Controller;
use App\Http\Requests\Customer\StoreOrderRequest;
use App\Http\Requests\Customer\CancelOrderRequest;
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
        return $this->orderService->getCustomerOrders(Auth::id());
    }

    public function store(StoreOrderRequest $request)
    {
        return $this->orderService->createOrder(Auth::id(), $request->validated());
    }

    public function show(int $id)
    {
        return $this->orderService->getCustomerOrder(Auth::id(), $id);
    }

    public function cancel(int $id, CancelOrderRequest $request)
    {
        return $this->orderService->cancelCustomerOrder(Auth::id(), $id);
    }

    public function destroy(int $id)
    {
        return $this->orderService->deleteCustomerOrder(Auth::id(), $id);
    }
}
