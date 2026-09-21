<?php

namespace App\Repositories;

use App\Models\Notification;
use Illuminate\Database\Eloquent\Collection;

class NotificationRepository
{
    public function getForUser(int $userId): Collection
    {
        return Notification::where('user_id', $userId)
            ->orderByDesc('created_at')
            ->get();
    }

    public function findForUser(int $userId, int $notificationId): ?Notification
    {
        return Notification::where('user_id', $userId)
            ->find($notificationId);
    }

    public function create(array $data): Notification
    {
        return Notification::create($data);
    }

    public function markAsRead(Notification $notification): Notification
    {
        $notification->read_at = now();
        $notification->save();

        return $notification;
    }
}
