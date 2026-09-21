<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        $users = DB::table('users')->get();
        $hasPhone = Schema::hasColumn('users', 'phone');
        $hasAvatar = Schema::hasColumn('users', 'avatar_path');

        foreach ($users as $user) {
            $attributes = [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'password' => $user->password,
                'created_at' => $user->created_at,
                'updated_at' => $user->updated_at,
            ];

            if (in_array($user->role, ['admin', 'manager'], true)) {
                DB::table('dashboard_users')->insert([
                    ...$attributes,
                    'role' => $user->role,
                    'remember_token' => null,
                ]);
            } elseif (in_array($user->role, ['customer', 'pharmacy_owner'], true)) {
                DB::table('app_users')->insert([
                    ...$attributes,
                    'phone' => $hasPhone ? $user->phone : null,
                    'role' => $user->role,
                    'avatar_path' => $hasAvatar ? $user->avatar_path : null,
                ]);
            }
        }
    }

    public function down(): void
    {
        DB::table('dashboard_users')->delete();
        DB::table('app_users')->delete();
    }
};
