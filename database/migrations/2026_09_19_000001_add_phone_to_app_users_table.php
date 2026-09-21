<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        if (!Schema::hasColumn('app_users', 'phone')) {
            Schema::table('app_users', function (Blueprint $table) {
                $table->string('phone')->nullable()->after('email');
            });
        }
    }

    public function down(): void
    {
        // The canonical app_users migration already defines this column.
    }
};
