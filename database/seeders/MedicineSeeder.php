<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Medicine;
use App\Models\Category;

class MedicineSeeder extends Seeder
{
    public function run(): void
    {
        // Ensure categories exist
        $categories = Category::all()->keyBy('name');

        $medicines = [
            [
                'category' => 'Painkillers',
                'name' => 'Paracetamol 500mg',
                'description' => 'Effective pain reliever and fever reducer.',
                'price' => 5.99,
                'discount_percentage' => 0,
                'quantity' => 100,
                'expiration_date' => '2027-12-31',
                'barcode' => '1234567890123',
            ],
            [
                'category' => 'Painkillers',
                'name' => 'Ibuprofen 200mg',
                'description' => 'Anti-inflammatory pain reliever.',
                'price' => 7.49,
                'discount_percentage' => 10,
                'quantity' => 80,
                'expiration_date' => '2027-06-30',
                'barcode' => '1234567890124',
            ],
            [
                'category' => 'Antibiotics',
                'name' => 'Amoxicillin 500mg',
                'description' => 'Broad-spectrum antibiotic.',
                'price' => 12.99,
                'discount_percentage' => 0,
                'quantity' => 50,
                'expiration_date' => '2026-11-30',
                'barcode' => '1234567890125',
            ],
            [
                'category' => 'Cough & Cold',
                'name' => 'Cough Syrup',
                'description' => 'Relieves cough and sore throat.',
                'price' => 9.99,
                'discount_percentage' => 5,
                'quantity' => 60,
                'expiration_date' => '2027-03-31',
                'barcode' => '1234567890126',
            ],
            [
                'category' => 'Allergy',
                'name' => 'Cetirizine 10mg',
                'description' => 'Antihistamine for allergy relief.',
                'price' => 11.49,
                'discount_percentage' => 0,
                'quantity' => 70,
                'expiration_date' => '2027-09-30',
                'barcode' => '1234567890127',
            ],
            [
                'category' => 'Vitamins & Supplements',
                'name' => 'Vitamin C 1000mg',
                'description' => 'Immune system support.',
                'price' => 14.99,
                'discount_percentage' => 15,
                'quantity' => 90,
                'expiration_date' => '2028-01-31',
                'barcode' => '1234567890128',
            ],
        ];

        foreach ($medicines as $medData) {
            $category = $categories[$medData['category']];
            if (!$category) {
                continue;
            }

            Medicine::create([
                'category_id' => $category->id,
                'name' => $medData['name'],
                'description' => $medData['description'],
                'price' => $medData['price'],
                'discount_percentage' => $medData['discount_percentage'],
                'quantity' => $medData['quantity'],
                'expiration_date' => $medData['expiration_date'],
                'barcode' => $medData['barcode'],
                'image_path' => null, // placeholder
            ]);
        }
    }
}