<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use App\Models\Pharmacy;

class PharmacySeeder extends Seeder
{
    public function run(): void
    {
        // Get the pharmacy owner user (role pharmacy_owner)
        $owner = User::where('role', 'pharmacy_owner')->first();

        if ($owner) {
            Pharmacy::create([
                'user_id' => $owner->id,
                'name' => 'HealthPlus Pharmacy',
                'address' => '123 Main Street, Anytown, USA',
                'phone' => '555-123-4567',
                'latitude' => 40.7128,
                'longitude' => -74.0060,
                'opening_time' => '08:00:00',
                'closing_time' => '20:00:00',
                'status' => 'open',
            ]);
        }
    }
}