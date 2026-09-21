<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::table('pharmacy_medicines', function (Blueprint $table) {
            if (!Schema::hasColumn('pharmacy_medicines', 'is_donation')) {
                $table->boolean('is_donation')->default(false)->after('is_available');
            }
            if (!Schema::hasColumn('pharmacy_medicines', 'is_near_expiry')) {
                $table->boolean('is_near_expiry')->default(false)->after('is_donation');
            }
        });
    }

    public function down(): void
    {
        Schema::table('pharmacy_medicines', function (Blueprint $table) {
            if (Schema::hasColumn('pharmacy_medicines', 'is_near_expiry')) {
                $table->dropColumn('is_near_expiry');
            }
            if (Schema::hasColumn('pharmacy_medicines', 'is_donation')) {
                $table->dropColumn('is_donation');
            }
        });
    }
};
