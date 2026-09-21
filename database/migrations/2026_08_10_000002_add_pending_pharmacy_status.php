<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration {
    public function up(): void
    {
        DB::table('pharmacies')
            ->whereNull('status')
            ->orWhere('status', '')
            ->update(['status' => 'closed']);

        DB::statement(
            "ALTER TABLE pharmacies MODIFY status ENUM('pending', 'open', 'closed') NOT NULL DEFAULT 'pending'"
        );
    }

    public function down(): void
    {
        DB::table('pharmacies')
            ->where('status', 'pending')
            ->update(['status' => 'closed']);

        DB::statement(
            "ALTER TABLE pharmacies MODIFY status ENUM('open', 'closed') NOT NULL DEFAULT 'closed'"
        );
    }
};
