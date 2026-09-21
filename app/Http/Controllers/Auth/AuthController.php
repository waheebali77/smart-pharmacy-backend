<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller as BaseController;
use App\Http\Requests\Auth\RegisterCustomerRequest;
use App\Http\Requests\Auth\RegisterPharmacyOwnerRequest;
use App\Http\Requests\Auth\LoginRequest;
use App\Http\Resources\UserResource;
use App\Services\AuthService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;
use App\Exceptions\PharmacySubscriptionExpiredException;

class AuthController extends BaseController
{
    protected AuthService $authService;

    public function __construct(AuthService $authService)
    {
        $this->authService = $authService;
    }

    /**
     * Register a new customer.
     *
     * @param  RegisterCustomerRequest  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function registerCustomer(RegisterCustomerRequest $request)
    {
        try {
            $result = $this->authService->registerCustomer($request->validated());

            return response()->json([
                'success' => true,
                'message' => 'Customer registered successfully',
                'data' => [
                    'user' => new UserResource($result['user']),
                    'token' => $result['token'],
                ],
            ], 201);
        } catch (ValidationException $e) {
            return response()->json([
                'message' => 'هناك خطأ في صحة البيانات المدخلة',
                'errors' => $e->errors(),
            ], 422);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Registration failed',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Register a new pharmacy owner.
     *
     * @param  RegisterPharmacyOwnerRequest  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function registerPharmacyOwner(RegisterPharmacyOwnerRequest $request)
    {
        try {
            $result = $this->authService->registerPharmacyOwner($request->validated());

            return response()->json([
                'success' => true,
                'message' => 'Pharmacy owner registered successfully',
                'data' => [
                    'user' => new UserResource($result['user']),
                    'token' => $result['token'],
                ],
            ], 201);
        } catch (ValidationException $e) {
            return response()->json([
                'message' => 'هناك خطأ في صحة البيانات المدخلة',
                'errors' => $e->errors(),
            ], 422);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Registration failed',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Login user.
     *
     * @param  LoginRequest  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function login(LoginRequest $request)
    {
        try {
            $result = $this->authService->login($request->validated());

            return response()->json([
                'success' => true,
                'message' => 'Login successful',
                'data' => [
                    'user' => new UserResource($result['user']),
                    'token' => $result['token'],
                ],
            ]);
        } catch (PharmacySubscriptionExpiredException $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 403);
        } catch (ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Authentication failed',
                'errors' => $e->errors(),
            ], 401);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Login failed',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Logout user.
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function logout()
    {
        try {
            $this->authService->logout();

            return response()->json([
                'success' => true,
                'message' => 'Logout successful',
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Logout failed',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    public function deleteAccount()
    {
        try {
            $this->authService->deleteAccount();

            return response()->json([
                'success' => true,
                'message' => 'Account deactivated successfully',
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Account deletion failed',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Refresh token.
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function refresh()
    {
        try {
            $token = $this->authService->refresh();

            return response()->json([
                'success' => true,
                'message' => 'Token refreshed successfully',
                'data' => [
                    'token' => $token,
                ],
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Token refresh failed',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get current user profile.
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function profile()
    {
        try {
            $user = $this->authService->getUser();

            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'User not found',
                ], 404);
            }

            return response()->json([
                'success' => true,
                'message' => 'Profile retrieved successfully',
                'data' => [
                    'user' => new UserResource($user),
                ],
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to retrieve profile',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Update user profile.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function updateProfile(Request $request)
    {
        try {
            $currentUser = $request->user('api');
            $validator = Validator::make($request->all(), [
                'name' => ['sometimes', 'string', 'max:255'],
                'email' => [
                    'sometimes',
                    'string',
                    'email',
                    'max:255',
                    'unique:app_users,email,' . ($currentUser?->id ?? 'NULL'),
                ],
                'phone' => ['sometimes', 'nullable', 'string', 'max:50'],
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Validation failed',
                    'errors' => $validator->errors(),
                ], 422);
            }

            $user = $this->authService->updateProfile($validator->validated());

            return response()->json([
                'success' => true,
                'message' => 'Profile updated successfully',
                'data' => [
                    'user' => new UserResource($user),
                ],
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Profile update failed',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    public function uploadAvatar(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'avatar' => ['required', 'image', 'mimes:jpeg,png,jpg,gif,webp', 'max:2048'],
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors(),
            ], 422);
        }

        $user = $this->authService->getUser();
        $path = $request->file('avatar')->store('user_avatars', 'public');
        $user->avatar_path = Storage::url($path);
        $user->save();

        return response()->json([
            'success' => true,
            'message' => 'Avatar updated successfully',
            'data' => ['user' => new UserResource($user)],
        ]);
    }

    /**
     * Change user password.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function changePassword(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'current_password' => ['required', 'string'],
                'password' => ['required', 'string', 'min:8', 'confirmed'],
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Validation failed',
                    'errors' => $validator->errors(),
                ], 422);
            }

            $this->authService->changePassword($validator->validated());

            return response()->json([
                'success' => true,
                'message' => 'Password changed successfully',
            ]);
        } catch (ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Password change failed',
                'errors' => $e->errors(),
            ], 422);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Password change failed',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Send password reset link.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function forgotPassword(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'email' => ['required', 'string', 'email'],
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Validation failed',
                    'errors' => $validator->errors(),
                ], 422);
            }

            $this->authService->forgotPassword($validator->validated()['email']);

            return response()->json([
                'success' => true,
                'message' => 'Password reset link sent successfully',
            ]);
        } catch (ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Password reset link sending failed',
                'errors' => $e->errors(),
            ], 422);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Password reset link sending failed',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Reset password.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function resetPassword(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'email' => ['required', 'string', 'email'],
                'token' => ['required', 'string'],
                'password' => ['required', 'string', 'min:8', 'confirmed'],
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Validation failed',
                    'errors' => $validator->errors(),
                ], 422);
            }

            $this->authService->resetPassword($validator->validated());

            return response()->json([
                'success' => true,
                'message' => 'Password reset successfully',
            ]);
        } catch (ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Password reset failed',
                'errors' => $e->errors(),
            ], 422);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Password reset failed',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    public function requestOtpReset(Request $request)
    {
            $validator = Validator::make($request->all(), [
                'phone' => ['required', 'string', 'max:30'],
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'يرجى إدخال رقم هاتف صحيح',
                    'errors' => $validator->errors(),
                ], 422);
            }

            $phone = trim($validator->validated()['phone']);
            $user = \App\Models\AppUser::where('phone', $phone)
                ->where('is_active', true)
                ->first();

            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'لا يوجد حساب مرتبط برقم الهاتف هذا',
                ], 404);
            }

            $otp = (string) random_int(100000, 999999);
            Cache::put("password_reset_otp:{$phone}", [
                'user_id' => $user->id,
                'otp' => Hash::make($otp),
            ], now()->addMinutes(5));

            // Replace this log with the SMS/WhatsApp provider in production.
            logger()->info('Password reset OTP generated', [
                'user_id' => $user->id,
                'phone' => $phone,
                'otp' => $otp,
            ]);

            return response()->json([
                'success' => true,
                'message' => 'تم إرسال رمز التحقق إلى رقم هاتفك',
            ]);
        }

        public function verifyOtpReset(Request $request)
        {
            $validator = Validator::make($request->all(), [
                'phone' => ['required', 'string', 'max:30'],
                'otp' => ['required', 'digits:6'],
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'رمز التحقق غير صالح',
                    'errors' => $validator->errors(),
                ], 422);
            }

            $data = $validator->validated();
            $record = Cache::get("password_reset_otp:{$data['phone']}");
            if (!is_array($record) || !Hash::check($data['otp'], $record['otp'] ?? '')) {
                return response()->json([
                    'success' => false,
                    'message' => 'رمز التحقق غير صحيح أو منتهي الصلاحية',
                ], 422);
            }

            $token = \Illuminate\Support\Str::random(64);
            Cache::put("password_reset_token:{$token}", [
                'user_id' => $record['user_id'],
                'phone' => $data['phone'],
            ], now()->addMinutes(10));
            Cache::forget("password_reset_otp:{$data['phone']}");

            return response()->json([
                'success' => true,
                'message' => 'تم التحقق من الرمز',
                'token' => $token,
            ]);
        }

        public function resetPasswordPhone(Request $request)
        {
            $validator = Validator::make($request->all(), [
                'phone' => ['required', 'string', 'max:30'],
                'token' => ['required', 'string'],
                'password' => ['required', 'string', 'min:8', 'confirmed'],
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'بيانات كلمة المرور غير صحيحة',
                    'errors' => $validator->errors(),
                ], 422);
            }

            $data = $validator->validated();
            $record = Cache::pull("password_reset_token:{$data['token']}");
            if (!is_array($record) ||
                $record['phone'] !== $data['phone']) {
                return response()->json([
                    'success' => false,
                    'message' => 'رمز إعادة التعيين غير صالح أو منتهي الصلاحية',
                ], 422);
            }

            $user = \App\Models\AppUser::whereKey($record['user_id'])
                ->where('phone', $data['phone'])
                ->where('is_active', true)
                ->first();
            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'الحساب غير موجود أو غير نشط',
                ], 404);
            }

            $user->update(['password' => Hash::make($data['password'])]);

            return response()->json([
                'success' => true,
                'message' => 'تم تغيير كلمة المرور بنجاح',
            ]);
    }
}