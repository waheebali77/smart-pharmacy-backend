<?php

return [
    'defaults' => [
        'guard' => 'web',
        'passwords' => 'dashboard_users',
    ],
    'guards' => [
        'web' => [
            'driver' => 'session',
            'provider' => 'dashboard_users',
        ],
        'api' => [
            'driver' => 'jwt',
            'provider' => 'app_users',
        ],
    ],
    'providers' => [
        'dashboard_users' => [
            'driver' => 'eloquent',
            'model' => App\Models\DashboardUser::class,
        ],
        'app_users' => [
            'driver' => 'eloquent',
            'model' => App\Models\AppUser::class,
        ],
    ],
    'passwords' => [
        'dashboard_users' => [
            'provider' => 'dashboard_users',
            'table' => 'password_reset_tokens',
            'expire' => 60,
            'throttle' => 60,
        ],
        'app_users' => [
            'provider' => 'app_users',
            'table' => 'password_reset_tokens',
            'expire' => 60,
            'throttle' => 60,
        ],
    ],
    'password_timeout' => 10800,
];