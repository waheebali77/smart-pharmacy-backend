<?php

namespace App\Providers;

use Illuminate\Support\Facades\URL;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    public function register(): void
    {
        //
    }

    public function boot(): void
    {
        $isBehindHttpsProxy =
            request()->header('X-Forwarded-Proto') === 'https';

        if (app()->environment('production') || $isBehindHttpsProxy) {
            URL::forceScheme('https');
        }
    }
}
