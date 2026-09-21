<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::table('pharmacy_medicines', function (Blueprint $table) {
            $table->decimal('price', 10, 2)->nullable()->after('quantity');
            $table->unsignedSmallInteger('discount_percentage')->default(0)->after('price');
            $table->date('expiration_date')->nullable()->after('discount_percentage');
            $table->string('barcode')->nullable()->after('expiration_date');
            $table->boolean('is_available')->default(false)->after('barcode');
        });
    }

    public function down(): void
    {
        Schema::table('pharmacy_medicines', function (Blueprint $table) {
            $table->dropColumn(['price', 'discount_percentage', 'expiration_date', 'barcode', 'is_available']);
        });
    }
};