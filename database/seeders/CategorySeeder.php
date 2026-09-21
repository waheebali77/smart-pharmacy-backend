<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Category;

class CategorySeeder extends Seeder
{
    public function run(): void
    {
        $categories = [
            [
                'name' => 'Painkillers',
                'description' => 'Medications for pain relief and fever reduction.'
            ],
            [
                'name' => 'Antibiotics',
                'description' => 'Drugs used to treat bacterial infections.'
            ],
            [
                'name' => 'Cough & Cold',
                'description' => 'Remedies for cough, cold, and flu symptoms.'
            ],
            [
                'name' => 'Allergy',
                'description' => 'Antihistamines and allergy relief products.'
            ],
            [
                'name' => 'Vitamins & Supplements',
                'description' => 'Nutritional supplements and vitamins.'
            ]
        ];

        foreach ($categories as $category) {
            Category::updateOrCreate(['name' => $category['name']], $category);
        }
    }
}