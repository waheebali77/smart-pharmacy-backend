<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        // Order of seeding: categories, users, pharmacies, medicines, offers, etc.
        $this->call([
            CategorySeeder::class,
            UserSeeder::class,
            PharmacySeeder::class,
            MedicineSeeder::class,
            OfferSeeder::class,
            AdminUserSeeder::class,
            // Additional seeders can be added here as needed
        ]);
    }
}