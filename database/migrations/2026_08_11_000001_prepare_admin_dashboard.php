<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration {
    public function up(): void
    {
        DB::statement("ALTER TABLE users MODIFY role ENUM('customer', 'pharmacy_owner', 'admin') NOT NULL");
        DB::statement("ALTER TABLE pharmacies MODIFY status ENUM('pending', 'open', 'closed', 'rejected') NOT NULL DEFAULT 'pending'");
    }

    public function down(): void
    {
        DB::table('users')->where('role', 'admin')->update(['role' => 'customer']);
        DB::table('pharmacies')->where('status', 'rejected')->update(['status' => 'closed']);
        DB::statement("ALTER TABLE users MODIFY role ENUM('customer', 'pharmacy_owner') NOT NULL");
        DB::statement("ALTER TABLE pharmacies MODIFY status ENUM('pending', 'open', 'closed') NOT NULL DEFAULT 'pending'");
    }
};