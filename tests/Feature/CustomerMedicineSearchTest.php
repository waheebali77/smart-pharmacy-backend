<?php

namespace Tests\Feature;

use App\Models\Category;
use App\Models\Medicine;
use App\Models\Pharmacy;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class CustomerMedicineSearchTest extends TestCase
{
    use RefreshDatabase;

    public function test_customer_search_returns_medicines_from_open_pharmacies(): void
    {
        $category = Category::create([
            'name' => 'Vitamins',
            'description' => 'Vitamin supplements',
        ]);

        $pharmacy = Pharmacy::create([
            'user_id' => 1,
            'name' => 'HealthPlus Pharmacy',
            'address' => '123 Main Street',
            'phone' => '123456789',
            'status' => 'open',
            'license_number' => 'ABC123',
        ]);

        $medicine = Medicine::create([
            'category_id' => $category->id,
            'name' => 'Vitamin C 1000mg',
            'description' => 'Vitamin C supplement',
            'is_available' => true,
            'price' => 14.99,
            'quantity' => 90,
        ]);

        $pharmacy->medicines()->attach($medicine->id, [
            'quantity' => 90,
            'price' => 14.99,
            'discount_percentage' => 15,
            'is_available' => true,
        ]);

        $response = $this->getJson('/api/customer/medicines/search?search=vitamin');

        $response->assertOk();
        $response->assertJsonFragment(['name' => 'Vitamin C 1000mg']);
    }
}
