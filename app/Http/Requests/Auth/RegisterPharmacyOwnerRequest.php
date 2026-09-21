<?php

namespace App\Http\Requests\Auth;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Http\Exceptions\HttpResponseException;
use Illuminate\Contracts\Validation\Validator;

class RegisterPharmacyOwnerRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        return true;
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'string', 'email', 'max:255', 'unique:app_users,email'],
            'password' => ['required', 'string', 'min:8', 'confirmed'],
            'pharmacy_name' => ['required', 'string', 'max:255'],
            'pharmacy_address' => ['required', 'string'],
            'pharmacy_phone' => ['required', 'string', 'max:20'],
            'pharmacy_license_number' => ['nullable', 'string', 'max:100'],
            'latitude' => ['required', 'numeric', 'between:-90,90'],
            'longitude' => ['required', 'numeric', 'between:-180,180'],
        ];
    }

    public function messages(): array
    {
        return [
            'email.unique' => 'هذا البريد الإلكتروني أو رقم الهاتف مسجل مسبقاً',
        ];
    }

    protected function failedValidation(Validator $validator): void
    {
        $errors = $validator->errors()->toArray();
        $duplicate = collect($errors['email'] ?? [])
            ->contains(
                fn (string $message): bool => str_contains($message, 'مسجل مسبقاً')
            );

        throw new HttpResponseException(response()->json([
            'message' => $duplicate
                ? 'هذا البريد الإلكتروني أو رقم الهاتف مسجل مسبقاً'
                : 'هناك خطأ في صحة البيانات المدخلة',
            'errors' => $errors,
        ], 422));
    }
}