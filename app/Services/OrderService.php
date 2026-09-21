<?php

namespace App\Services;

use App\Models\Notification;
use App\Models\ActivityLog;
use App\Models\Medicine;
use App\Models\PharmacyMedicine;
use App\Models\Order;
use App\Repositories\OrderRepository;
use App\Http\Resources\OrderResource;
use Illuminate\Database\Eloquent\ModelNotFoundException;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;

class OrderService
{
    protected OrderRepository $repository;

    public function __construct(OrderRepository $repository)
    {
        $this->repository = $repository;
    }

    public function createOrder(int $userId, array $payload): OrderResource
    {
        $pharmacyId = $payload['pharmacy_id'];
        $items = $payload['items'];

        $orderItems = [];
        $totalPrice = 0;
        $order = null;

        DB::transaction(function () use ($userId, $pharmacyId, $items, &$orderItems, &$totalPrice, &$order) {
            foreach ($items as $item) {
                $medicine = Medicine::find($item['medicine_id']);

                if (!$medicine) {
                    throw new ModelNotFoundException("Medicine not found: {$item['medicine_id']}");
                }

                $pharmacyMedicine = PharmacyMedicine::where('pharmacy_id', $pharmacyId)
                    ->where('medicine_id', $medicine->id)
                    ->first();

                if (!$pharmacyMedicine || $pharmacyMedicine->quantity < $item['quantity']) {
                    throw new \InvalidArgumentException("Insufficient quantity for medicine ID {$medicine->id} in selected pharmacy.");
                }

                $basePrice = $pharmacyMedicine->price ?? $medicine->price;
                $discountPercentage = $pharmacyMedicine->discount_percentage
                    ?? $medicine->discount_percentage
                    ?? 0;
                $price = (float) $basePrice * (1 - ((float) $discountPercentage / 100));
                $lineTotal = $price * $item['quantity'];
                $totalPrice += $lineTotal;

                $orderItems[] = [
                    'medicine_id' => $medicine->id,
                    'quantity' => $item['quantity'],
                    'price' => round($price, 2),
                ];
            }

            $order = $this->repository->createOrder([
                'user_id' => $userId,
                'pharmacy_id' => $pharmacyId,
                'status' => 'pending',
                'total_price' => round($totalPrice, 2),
            ]);

            $this->repository->createOrderItems($order, $orderItems);

            foreach ($items as $item) {
                $this->reserveStock($pharmacyId, $item['medicine_id'], $item['quantity']);
            }

            $this->createNotificationForOwner($order, 'order.created', [
                'order_id' => $order->id,
                'message' => 'New pickup order placed',
            ]);

            $this->createActivityLog($userId, $pharmacyId, 'order.created', [
                'order_id' => $order->id,
                'status' => 'pending',
            ]);
        });

        if (!$order) {
            throw new \RuntimeException('Order could not be created.');
        }

        return new OrderResource($this->repository->getOrderById($order->id));
    }

    public function getCustomerOrders(int $userId)
    {
        return OrderResource::collection($this->repository->getCustomerOrders($userId));
    }

    public function getCustomerOrder(int $userId, int $orderId): OrderResource
    {
        $order = $this->repository->getCustomerOrder($userId, $orderId);

        if (!$order) {
            throw new ModelNotFoundException('Order not found.');
        }

        return new OrderResource($order);
    }

    public function getPharmacyOrders(int $ownerId)
    {
        $pharmacy = Auth::user()->pharmacy;

        if (!$pharmacy) {
            throw new ModelNotFoundException('Pharmacy not found for owner.');
        }

        return OrderResource::collection($this->repository->getPharmacyOrders($pharmacy->id));
    }

    public function getPharmacyOrder(int $ownerId, int $orderId): OrderResource
    {
        $pharmacy = Auth::user()->pharmacy;

        if (!$pharmacy) {
            throw new ModelNotFoundException('Pharmacy not found for owner.');
        }

        $order = $this->repository->getPharmacyOrder($pharmacy->id, $orderId);

        if (!$order) {
            throw new ModelNotFoundException('Order not found.');
        }

        return new OrderResource($order);
    }

    public function updateOrderStatusByOwner(int $ownerId, int $orderId, string $status): OrderResource
    {
        $pharmacy = Auth::user()->pharmacy;
        if (!$pharmacy) {
            throw new ModelNotFoundException('Pharmacy not found for owner.');
        }

        $order = $this->repository->getPharmacyOrder($pharmacy->id, $orderId);

        if (!$order) {
            throw new ModelNotFoundException('Order not found.');
        }

        $this->validateStatusTransition($order->status, $status);

        if (in_array($status, ['rejected', 'cancelled']) && !in_array($order->status, ['cancelled', 'rejected', 'delivered'])) {
            $this->restoreStock($order);
        }

        $updated = $this->repository->updateOrderStatus($order, $status);

        $this->createNotificationForCustomer($order, 'order.status_updated', [
            'order_id' => $order->id,
            'status' => $status,
            'message' => 'Order status updated',
        ]);

        $this->createActivityLog($order->user_id, $order->pharmacy_id, 'order.status_updated', [
            'order_id' => $order->id,
            'old_status' => $order->status,
            'new_status' => $status,
        ]);

        return new OrderResource($updated->refresh());
    }

    public function cancelCustomerOrder(int $userId, int $orderId): OrderResource
    {
        $order = $this->repository->getCustomerOrder($userId, $orderId);

        if (!$order) {
            throw new ModelNotFoundException('Order not found.');
        }

        if (in_array($order->status, ['delivered', 'cancelled', 'rejected'])) {
            throw new \InvalidArgumentException('Order cannot be cancelled.');
        }

        if (!in_array($order->status, ['pending', 'accepted', 'preparing', 'ready'])) {
            throw new \InvalidArgumentException('Order cannot be cancelled in its current state.');
        }

        $this->restoreStock($order);

        $updated = $this->repository->updateOrderStatus($order, 'cancelled');

        $this->createNotificationForOwner($order, 'order.cancelled', [
            'order_id' => $order->id,
            'message' => 'Customer cancelled the order',
        ]);

        $this->createActivityLog($order->user_id, $order->pharmacy_id, 'order.cancelled', [
            'order_id' => $order->id,
            'status' => 'cancelled',
        ]);

        return new OrderResource($updated->refresh());
    }

    public function deleteCustomerOrder(int $userId, int $orderId): void
    {
        $order = $this->repository->getCustomerOrder($userId, $orderId);

        if (!$order) {
            throw new ModelNotFoundException('Order not found.');
        }

        if (!in_array($order->status, ['delivered', 'cancelled', 'rejected'], true)) {
            throw new \InvalidArgumentException('Only completed, cancelled, or rejected orders can be deleted.');
        }

        $order->delete();
    }

    protected function validateStatusTransition(string $current, string $next): void
    {
        $allowed = [
            'pending' => ['accepted', 'rejected', 'cancelled'],
            'accepted' => ['preparing', 'cancelled'],
            'preparing' => ['ready', 'cancelled'],
            'ready' => ['delivered', 'cancelled'],
            'delivered' => [],
            'rejected' => [],
            'cancelled' => [],
        ];

        if (!isset($allowed[$current]) || !in_array($next, $allowed[$current], true)) {
            throw new \InvalidArgumentException("Invalid order status transition from {$current} to {$next}.");
        }
    }

    protected function reserveStock(int $pharmacyId, int $medicineId, int $quantity): void
    {
        $pivot = PharmacyMedicine::where('pharmacy_id', $pharmacyId)
            ->where('medicine_id', $medicineId)
            ->first();

        if (!$pivot) {
            throw new ModelNotFoundException('Pharmacy medicine record not found.');
        }

        if ($pivot->quantity < $quantity) {
            throw new \InvalidArgumentException('Insufficient stock for medicine.');
        }

        $pivot->decrement('quantity', $quantity);

        $medicine = Medicine::find($medicineId);
        if ($medicine && $medicine->quantity !== null) {
            $medicine->decrement('quantity', $quantity);
        }
    }

    protected function restoreStock(Order $order): void
    {
        foreach ($order->items as $item) {
            $pivot = PharmacyMedicine::firstOrCreate([
                'pharmacy_id' => $order->pharmacy_id,
                'medicine_id' => $item->medicine_id,
            ], ['quantity' => 0]);

            $pivot->increment('quantity', $item->quantity);

            $medicine = Medicine::find($item->medicine_id);
            if ($medicine && $medicine->quantity !== null) {
                $medicine->increment('quantity', $item->quantity);
            }
        }
    }

    protected function createNotificationForOwner(Order $order, string $type, array $data): void
    {
        $ownerId = $order->pharmacy?->user_id;

        if (!$ownerId) {
            $ownerId = optional($order->pharmacy()->first())->user_id;
        }

        if (!$ownerId) {
            return;
        }

        Notification::create([
            'user_id' => $ownerId,
            'pharmacy_id' => $order->pharmacy_id,
            'type' => $type,
            'data' => json_encode($data),
        ]);
    }

    protected function createNotificationForCustomer(Order $order, string $type, array $data): void
    {
        Notification::create([
            'user_id' => $order->user_id,
            'pharmacy_id' => $order->pharmacy_id,
            'type' => $type,
            'data' => json_encode($data),
        ]);
    }

    protected function createActivityLog(int $userId, int $pharmacyId, string $type, array $data): void
    {
        ActivityLog::create([
            'user_id' => $userId,
            'pharmacy_id' => $pharmacyId,
            'type' => $type,
            'data' => json_encode($data),
        ]);
    }
}
