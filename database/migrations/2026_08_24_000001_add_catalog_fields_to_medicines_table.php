<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::table('medicines', function (Blueprint $table) {
            $table->string('generic_name')->nullable()->after('name');
            $table->string('manufacturer')->nullable()->after('description');
            $table->string('dosage_form')->nullable()->after('manufacturer');
            $table->string('strength')->nullable()->after('dosage_form');
            $table->boolean('requires_prescription')->default(false)->after('is_available');
            $table->decimal('price', 10, 2)->nullable()->change();
            $table->integer('quantity')->nullable()->change();
        });
    }

    public function down(): void
    {
        Schema::table('medicines', function (Blueprint $table) {
            $table->dropColumn([
                'generic_name',
                'manufacturer',
                'dosage_form',
                'strength',
                'requires_prescription',
            ]);
            $table->decimal('price', 10, 2)->nullable(false)->change();
            $table->integer('quantity')->nullable(false)->change();
        });
    }
};
