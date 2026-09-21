<?php

namespace App\Repositories;

use App\Models\Order;
use App\Models\OrderItem;
use Illuminate\Database\Eloquent\Collection;

class OrderRepository
{
    public function getCustomerOrders(int $userId): Collection
    {
        return Order::with(['items.medicine', 'pharmacy'])
            ->where('user_id', $userId)
            ->orderByDesc('created_at')
            ->get();
    }

    public function getCustomerOrder(int $userId, int $orderId): ?Order
    {
        return Order::with(['items.medicine', 'pharmacy', 'user'])
            ->where('user_id', $userId)
            ->find($orderId);
    }

    public function getPharmacyOrders(int $pharmacyId): Collection
    {
        return Order::with(['items.medicine', 'user'])
            ->where('pharmacy_id', $pharmacyId)
            ->orderByDesc('created_at')
            ->get();
    }

    public function getPharmacyOrder(int $pharmacyId, int $orderId): ?Order
    {
        return Order::with(['items.medicine', 'user', 'pharmacy'])
            ->where('pharmacy_id', $pharmacyId)
            ->find($orderId);
    }

    public function getOrderById(int $orderId): ?Order
    {
        return Order::with(['items.medicine', 'pharmacy', 'user'])->find($orderId);
    }

    public function createOrder(array $data): Order
    {
        return Order::create($data);
    }

    public function createOrderItems(Order $order, array $items): void
    {
        foreach ($items as $item) {
            OrderItem::create(array_merge($item, ['order_id' => $order->id]));
        }
    }

    public function updateOrderStatus(Order $order, string $status): Order
    {
        $order->status = $status;
        $order->save();

        return $order;
    }
}
