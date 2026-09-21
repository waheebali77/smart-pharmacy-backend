<?php

namespace App\Http\Middleware;

use App\Exceptions\PharmacySubscriptionExpiredException;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class CheckPharmacySubscription
{
    public function handle(Request $request, Closure $next): Response
    {
        $user = $request->user('api');

        if ($user?->role === 'pharmacy_owner' && !$user->is_active) {
            return response()->json([
                'success' => false,
                'message' => PharmacySubscriptionExpiredException::MESSAGE,
            ], 403);
        }

        return $next($request);
    }
}
