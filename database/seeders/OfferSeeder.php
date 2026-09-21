<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Offer;
use App\Models\Pharmacy;

class OfferSeeder extends Seeder
{
    public function run(): void
    {
        // Get the first pharmacy (assuming we have one)
        $pharmacy = Pharmacy::first();

        if ($pharmacy) {
            Offer::create([
                'pharmacy_id' => $pharmacy->id,
                'title' => 'Winter Wellness Sale',
                'description' => '20% off all vitamins and supplements.',
                'discount_percentage' => 20,
                'start_date' => now()->toDateString(),
                'end_date' => now()->addMonth()->toDateString(),
                'image_path' => null,
            ]);

            Offer::create([
                'pharmacy_id' => $pharmacy->id,
                'title' => 'Buy One Get One Free',
                'description' => 'BOGO on selected painkillers.',
                'discount_percentage' => 50,
                'start_date' => now()->toDateString(),
                'end_date' => now()->addWeek()->toDateString(),
                'image_path' => null,
            ]);
        }
    }
}