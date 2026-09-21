<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::table('activity_logs', function (Blueprint $table) {
            $table->unsignedBigInteger('dashboard_user_id')->nullable()->after('user_id');
        });

        Schema::table('activity_logs', function (Blueprint $table) {
            $table->dropForeign(['user_id']);
        });
        DB::statement('ALTER TABLE activity_logs MODIFY user_id BIGINT UNSIGNED NULL');

        DB::table('activity_logs')->whereIn('user_id', function ($query) {
            $query->select('id')->from('dashboard_users');
        })->update([
            'dashboard_user_id' => DB::raw('user_id'),
            'user_id' => null,
        ]);

        foreach (['notifications', 'orders', 'pharmacies'] as $tableName) {
            Schema::table($tableName, function (Blueprint $table) {
                $table->dropForeign(['user_id']);
            });
        }

        Schema::table('activity_logs', function (Blueprint $table) {
            $table->foreign('user_id')->references('id')->on('app_users')->nullOnDelete();
            $table->foreign('dashboard_user_id')->references('id')->on('dashboard_users')->nullOnDelete();
        });

        foreach (['notifications', 'orders', 'pharmacies'] as $tableName) {
            Schema::table($tableName, function (Blueprint $table) {
                $table->foreign('user_id')->references('id')->on('app_users')->cascadeOnDelete();
            });
        }

        Schema::dropIfExists('users');
    }

    public function down(): void
    {
        throw new RuntimeException('The legacy users table cannot be restored automatically.');
    }
};
