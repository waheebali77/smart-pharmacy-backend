<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        DB::statement("UPDATE pharmacies SET opening_time = '08:00:00' WHERE opening_time IS NULL OR CAST(opening_time AS CHAR) = ''");
        DB::statement("UPDATE pharmacies SET closing_time = '22:00:00' WHERE closing_time IS NULL OR CAST(closing_time AS CHAR) = ''");

        Schema::table('pharmacies', function (Blueprint $table) {
            $table->time('opening_time')->default('08:00:00')->change();
            $table->time('closing_time')->default('22:00:00')->change();
            $table->boolean('is_manually_closed')->default(false)->change();
            $table->string('manual_status')->nullable()->default('open')->change();
            $table->enum('status', ['open', 'closed'])->default('open')->change();
        });
    }

    public function down(): void
    {
        Schema::table('pharmacies', function (Blueprint $table) {
            $table->time('opening_time')->nullable()->default(null)->change();
            $table->time('closing_time')->nullable()->default(null)->change();
            $table->boolean('is_manually_closed')->default(false)->change();
            $table->string('manual_status')->nullable()->default(null)->change();
            $table->enum('status', ['open', 'closed'])->default('closed')->change();
        });
    }
};
