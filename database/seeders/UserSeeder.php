<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use App\Models\AppUser;

class UserSeeder extends Seeder
{
    public function run(): void
    {
        // Create a pharmacy owner user
        AppUser::updateOrCreate(['email' => 'owner@example.com'], [
            'name' => 'John Pharmacy Owner',
            'email' => 'owner@example.com',
            'password' => Hash::make('password'),
            'role' => 'pharmacy_owner',
        ]);

        // Create a customer user
        AppUser::updateOrCreate(['email' => 'customer@example.com'], [
            'name' => 'Jane Customer',
            'email' => 'customer@example.com',
            'password' => Hash::make('password'),
            'role' => 'customer',
        ]);

        // Create test user for mobile app
        AppUser::updateOrCreate(['email' => 'wa@gmail.com'], [
            'name' => 'Test User 1',
            'email' => 'wa@gmail.com',
            'password' => Hash::make('111111111'),
            'role' => 'customer',
        ]);

        // Create another test user for mobile app
        AppUser::updateOrCreate(['email' => 'aw@gmail.com'], [
            'name' => 'Test User 2',
            'email' => 'aw@gmail.com',
            'password' => Hash::make('111111111'),
            'role' => 'customer',
        ]);
    }
}