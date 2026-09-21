<?php

namespace App\Repositories;

use App\Models\AppUser;
use App\Models\Pharmacy;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\DB;

class AuthRepository
{
    /**
     * Create a new customer user.
     *
     * @param array $data
     * @return User
     */
    public function createCustomer(array $data): AppUser
    {
        return AppUser::create([
            'name' => $data['name'],
            'email' => $data['email'],
            'phone' => $data['phone'],
            'password' => Hash::make($data['password']),
            'role' => 'customer',
        ]);
    }

    /**
     * Create a new pharmacy owner user and associated pharmacy.
     *
     * @param array $data
     * @return User
     */
    public function createPharmacyOwner(array $data): AppUser
    {
        return DB::transaction(function () use ($data) {
            $user = AppUser::create([
                'name' => $data['name'],
                'email' => $data['email'],
                'password' => Hash::make($data['password']),
                'role' => 'pharmacy_owner',
                'trial_ends_at' => now()->addDays(30),
                'is_active' => true,
            ]);

            $user->pharmacy()->create([
                'name' => $data['pharmacy_name'],
                'address' => $data['pharmacy_address'],
                'phone' => $data['pharmacy_phone'],
                'license_number' => $data['pharmacy_license_number'],
                'latitude' => $data['latitude'],
                'longitude' => $data['longitude'],
                'opening_time' => '08:00:00',
                'closing_time' => '22:00:00',
                'status' => 'open',
                'is_manually_closed' => false,
                'manual_status' => 'open',
            ]);

            return $user;
        });
    }

    /**
     * Find user by email.
     *
     * @param string $email
    * @return AppUser|null
     */
    public function findByEmail(string $email): ?AppUser
    {
        return AppUser::where('email', $email)->first();
    }

    /**
     * Find user by ID.
     *
     * @param int $id
     * @return User|null
     */
    public function findById(int $id): ?AppUser
    {
        return AppUser::find($id);
    }

    /**
     * Update user profile.
     *
    * @param AppUser $user
     * @param array $data
    * @return AppUser
     */
    public function updateProfile(AppUser $user, array $data): AppUser
    {
        $user->update($data);
        return $user;
    }

    /**
     * Update user password.
     *
    * @param AppUser $user
     * @param string $password
     * @return void
     */
    public function updatePassword(AppUser $user, string $password): void
    {
        $user->update(['password' => bcrypt($password)]);
    }

    public function deleteUser(AppUser $user): void
    {
        $user->forceFill(['is_active' => false])->save();
    }
}