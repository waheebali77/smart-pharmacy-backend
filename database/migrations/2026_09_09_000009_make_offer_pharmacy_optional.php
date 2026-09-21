<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::table('offers', function (Blueprint $table) {
            $table->dropForeign(['pharmacy_id']);
        });

        Schema::table('offers', function (Blueprint $table) {
            $table->foreignId('pharmacy_id')->nullable()->change();
            $table->foreign('pharmacy_id')->references('id')->on('pharmacies')->nullOnDelete();
        });
    }

    public function down(): void
    {
        Schema::table('offers', function (Blueprint $table) {
            $table->dropForeign(['pharmacy_id']);
            $table->foreignId('pharmacy_id')->nullable(false)->change();
            $table->foreign('pharmacy_id')->references('id')->on('pharmacies')->cascadeOnDelete();
        });
    }
};
