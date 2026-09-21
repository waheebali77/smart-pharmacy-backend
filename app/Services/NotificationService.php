<?php

namespace App\Services;

use App\Repositories\NotificationRepository;
use App\Http\Resources\NotificationResource;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

class NotificationService
{
    protected NotificationRepository $repository;

    public function __construct(NotificationRepository $repository)
    {
        $this->repository = $repository;
    }

    public function getUserNotifications(int $userId): AnonymousResourceCollection
    {
        return NotificationResource::collection($this->repository->getForUser($userId));
    }

    public function markNotificationAsRead(int $userId, int $notificationId)
    {
        $notification = $this->repository->findForUser($userId, $notificationId);

        if (!$notification) {
            throw new \RuntimeException('Notification not found.');
        }

        return new NotificationResource($this->repository->markAsRead($notification));
    }
}
