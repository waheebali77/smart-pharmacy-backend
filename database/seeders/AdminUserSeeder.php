<?php

namespace Database\Seeders;

use App\Models\DashboardUser;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class AdminUserSeeder extends Seeder
{
    public function run(): void
    {
        DashboardUser::updateOrCreate(
            ['email' => 'admin@smartpharmacy.test'],
            ['name' => 'System Administrator', 'password' => Hash::make('password'), 'role' => 'admin']
        );
    }
}