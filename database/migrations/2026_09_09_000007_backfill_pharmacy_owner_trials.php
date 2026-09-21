<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration {
    public function up(): void
    {
        DB::statement("UPDATE app_users SET trial_ends_at = DATE_ADD(created_at, INTERVAL 30 DAY) WHERE role = 'pharmacy_owner' AND trial_ends_at IS NULL");
    }

    public function down(): void
    {
        DB::table('app_users')
            ->where('role', 'pharmacy_owner')
            ->update(['trial_ends_at' => null]);
    }
};
