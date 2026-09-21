<?php

namespace App\Http\Controllers\Customer;

use App\Http\Controllers\Controller;
use App\Services\NotificationService;
use Illuminate\Support\Facades\Auth;

class NotificationController extends Controller
{
    protected NotificationService $notificationService;

    public function __construct(NotificationService $notificationService)
    {
        $this->notificationService = $notificationService;
    }

    public function index()
    {
        return $this->notificationService->getUserNotifications(Auth::id());
    }

    public function markAsRead(int $id)
    {
        return $this->notificationService->markNotificationAsRead(Auth::id(), $id);
    }
}
