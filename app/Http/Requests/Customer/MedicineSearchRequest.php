<?php

namespace App\Http\Requests\Customer;

use Illuminate\Foundation\Http\FormRequest;

class MedicineSearchRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     *
     * @return bool
     */
    public function authorize()
    {
        // For now, we allow all requests. In a real app, you might check authentication.
        return true;
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, mixed>
     */
    public function rules()
    {
        return [
            'search' => 'nullable|string|max:255',
            'category_id' => 'nullable|integer|exists:categories,id',
            'nearest_pharmacy' => 'nullable|boolean', // This is a flag, we don't sort here, we just note it.
            'lowest_price' => 'nullable|boolean', // Flag
            'available_only' => 'nullable|boolean', // Flag to show only medicines with quantity > 0
            'open_only' => 'nullable|boolean', // This is for pharmacies, but we are searching medicines. We might ignore or use to filter by pharmacy status.
            'donations_only' => 'nullable|boolean',
            'clearance_only' => 'nullable|boolean',
            // Note: The filters 'nearest_pharmacy', 'lowest_price', 'available_only', 'open_only' are flags.
            // The actual sorting/filtering will be done in the service or controller based on these flags.
        ];
    }

    /**
     * Get custom messages for validator errors.
     *
     * @return array
     */
    public function messages()
    {
        return [
            //
        ];
    }
}