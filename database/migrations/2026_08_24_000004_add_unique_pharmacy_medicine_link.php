<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::table('pharmacy_medicines', function (Blueprint $table) {
            $table->unique(['pharmacy_id', 'medicine_id'], 'pharmacy_medicines_pharmacy_medicine_unique');
        });
    }

    public function down(): void
    {
        Schema::table('pharmacy_medicines', function (Blueprint $table) {
            $table->dropUnique('pharmacy_medicines_pharmacy_medicine_unique');
        });
    }
};