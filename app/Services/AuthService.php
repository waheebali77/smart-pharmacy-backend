<?php

namespace App\Services;

use App\Repositories\AuthRepository;
use App\Models\AppUser;
use Illuminate\Support\Facades\Auth;
use Tymon\JWTAuth\Facades\JWTAuth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\Password;
use Illuminate\Auth\Events\PasswordReset;
use Illuminate\Http\Exceptions\HttpResponseException;
use Illuminate\Validation\ValidationException;

class AuthService
{
    protected $repository;

    public function __construct(AuthRepository $repository)
    {
        $this->repository = $repository;
    }

    /**
     * Register a new customer.
     *
     * @param array $data
     * @return array
     */
    public function registerCustomer(array $data): array
    {
        $user = $this->repository->createCustomer($data);

        $token = JWTAuth::fromUser($user);

        return [
            'user' => $user,
            'token' => $token,
        ];
    }

    /**
     * Register a new pharmacy owner.
     *
     * @param array $data
     * @return array
     */
    public function registerPharmacyOwner(array $data): array
    {
        $user = $this->repository->createPharmacyOwner($data);

        $token = JWTAuth::fromUser($user);

        return [
            'user' => $user,
            'token' => $token,
        ];
    }

    /**
     * Login user and return token.
     *
     * @param array $data
     * @return array
     * @throws ValidationException
     */
    public function login(array $data): array
    {
        $credentials = $data;

        $identifier = trim($credentials['phone'] ?? $credentials['email'] ?? '');
        $user = !empty($credentials['phone'])
            ? \App\Models\AppUser::where('phone', $identifier)->first()
            : $this->repository->findByEmail($identifier);
        if ($user && !$user->is_active) {
            throw ValidationException::withMessages([
                'email' => ['This account has been deactivated.'],
            ]);
        }

        // Primary attempt using the configured JWT guard
        $guard = Auth::guard('api');
        $guardCredentials = [
            'email' => $user?->email ?? $identifier,
            'password' => $credentials['password'] ?? '',
        ];
        if ($token = $guard->attempt($guardCredentials)) {
            return [
            'user' => $guard->user(),
                'token' => $token,
            ];
        }

        // Fallback: directly verify the user's password and issue a token.
        // This helps in development where guard/attempt may misbehave or when
        // requests are arriving in unexpected formats. It still enforces
        // proper password hashing checks.
        $email = $user?->email;
        $password = $data['password'] ?? null;

        if ($email && $password) {
            if ($user && \Illuminate\Support\Facades\Hash::check($password, $user->password)) {
                // Log the user in and issue a token
                $guard->login($user);
                $token = JWTAuth::fromUser($user);
                return [
                    'user' => $user,
                    'token' => $token,
                ];
            }
        }

        throw ValidationException::withMessages([
            'email' => ['The provided credentials are incorrect.'],
        ]);
    }

    /**
     * Logout user (invalidate token).
     *
     * @return void
     */
    public function logout(): void
    {
        $token = JWTAuth::getToken();

        if ($token) {
            JWTAuth::invalidate($token);
        }
    }

    public function deleteAccount(): void
    {
        $user = $this->currentAppUser();
        if (!$user) {
            return;
        }

        $token = JWTAuth::getToken();
        if ($token) {
            JWTAuth::invalidate($token);
        }

        $this->repository->deleteUser($user);
    }

    /**
     * Refresh token.
     *
     * @return string
     */
    public function refresh(): string
    {
        $token = JWTAuth::getToken();

        if (!$token) {
            throw ValidationException::withMessages([
                'token' => ['Token not provided.'],
            ]);
        }

        return JWTAuth::refresh($token);
    }

    /**
     * Get current authenticated user.
     *
     * @return AppUser|null
     */
    public function getUser(): ?AppUser
    {
        return $this->currentAppUser();
    }

    /**
     * Update user profile.
     *
     * @param array $data
     * @return AppUser
     */
    public function updateProfile(array $data): AppUser
    {
        $user = $this->currentAppUser();
        $this->repository->updateProfile($user, $data);
        return $user;
    }

    /**
     * Change user password.
     *
     * @param array $data
     * @return void
     * @throws ValidationException
     */
    public function changePassword(array $data): void
    {
        $user = $this->currentAppUser();

        if (! Hash::check($data['current_password'], $user->password)) {
            throw ValidationException::withMessages([
                'current_password' => ['The current password is incorrect.'],
            ]);
        }

        $this->repository->updatePassword($user, $data['password']);
    }

    private function currentAppUser(): ?AppUser
    {
        $user = JWTAuth::parseToken()->authenticate();

        return $user instanceof AppUser ? $user : null;
    }

    /**
     * Send password reset link.
     *
     * @param string $email
     * @return void
     * @throws ValidationException
     */
    public function forgotPassword(string $email): void
    {
        $response = Password::broker('app_users')->sendResetLink([
            'email' => $email,
        ]);

        if ($response !== Password::RESET_LINK_SENT) {
            throw ValidationException::withMessages([
                'email' => [$this->passwordResetMessage($response)],
            ]);
        }
    }

    private function passwordResetMessage(string $status): string
    {
        return match ($status) {
            Password::INVALID_USER => 'No account was found for this email address.',
            Password::RESET_THROTTLED => 'Please wait before requesting another reset link.',
            default => 'Password reset link could not be sent.',
        };
    }

    /**
     * Reset password.
     *
     * @param array $data
     * @return void
     * @throws ValidationException
     */
    public function resetPassword(array $data): void
    {
        $response = Password::reset(
            $data,
            function ($user, $password) {
                $this->repository->updatePassword($user, $password);
                event(new PasswordReset($user));
            }
        );

        if ($response !== Password::PASSWORD_RESET) {
            throw ValidationException::withMessages([
                'email' => [__($response)],
            ]);
        }
    }
}