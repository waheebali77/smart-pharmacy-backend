<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::table('medicines', function (Blueprint $table) {
            if (!Schema::hasColumn('medicines', 'is_available')) {
                $table->boolean('is_available')->default(true)->after('quantity');
            }
        });

        Schema::table('pharmacies', function (Blueprint $table) {
            if (!Schema::hasColumn('pharmacies', 'images')) {
                $table->json('images')->nullable()->after('status');
            }
        });
    }

    public function down(): void
    {
        Schema::table('medicines', function (Blueprint $table) {
            $table->dropColumn('is_available');
        });

        Schema::table('pharmacies', function (Blueprint $table) {
            $table->dropColumn('images');
        });
    }
};
