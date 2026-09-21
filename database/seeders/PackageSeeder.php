<?php

namespace Database\Seeders;

use App\Models\Package;
use Illuminate\Database\Seeder;

class PackageSeeder extends Seeder
{
    public function run(): void
    {
        Package::upsert([
            [
                'name' => 'Monthly',
                'price' => 15.00,
                'duration_in_days' => 30,
                'description' => 'Monthly access for pharmacy owners.',
                'is_active' => true,
            ],
            [
                'name' => 'Yearly',
                'price' => 150.00,
                'duration_in_days' => 365,
                'description' => 'Yearly access with better value.',
                'is_active' => true,
            ],
            [
                'name' => 'VIP',
                'price' => 300.00,
                'duration_in_days' => 365,
                'description' => 'Premium access for high-volume pharmacies.',
                'is_active' => true,
            ],
        ], ['name'], ['price', 'duration_in_days', 'description', 'is_active', 'updated_at']);
    }
}
