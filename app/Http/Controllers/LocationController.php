<?php

namespace App\Http\Controllers;

use App\Models\Country;
use App\Models\Governorate;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class LocationController extends Controller
{
    public function index(): JsonResponse
    {
        return response()->json([
            'data' => Country::query()
                ->with('governorates')
                ->orderBy('name_en')
                ->get(),
        ]);
    }

    public function storeCountry(Request $request): JsonResponse
    {
        $data = $request->validate([
            'name_ar' => ['required', 'string', 'max:255'],
            'name_en' => ['required', 'string', 'max:255'],
            'code' => ['required', 'string', 'size:2', 'alpha', 'unique:countries,code'],
        ]);
        $data['code'] = strtoupper($data['code']);

        return response()->json([
            'message' => 'Country created successfully.',
            'data' => Country::create($data),
        ], 201);
    }

    public function storeGovernorate(
        Request $request,
        Country $country
    ): JsonResponse {
        $data = $request->validate([
            'name_ar' => ['required', 'string', 'max:255'],
            'name_en' => ['required', 'string', 'max:255'],
        ]);
        $data['country_id'] = $country->id;

        return response()->json([
            'message' => 'Governorate created successfully.',
            'data' => $country->governorates()->create($data),
        ], 201);
    }

    public function updateCountry(
        Request $request,
        Country $country
    ): JsonResponse {
        $data = $request->validate([
            'name_ar' => ['sometimes', 'required', 'string', 'max:255'],
            'name_en' => ['sometimes', 'required', 'string', 'max:255'],
            'code' => [
                'sometimes',
                'required',
                'string',
                'size:2',
                'alpha',
                Rule::unique('countries', 'code')->ignore($country->id),
            ],
        ]);
        if (isset($data['code'])) {
            $data['code'] = strtoupper($data['code']);
        }
        $country->update($data);

        return response()->json([
            'message' => 'Country updated successfully.',
            'data' => $country->fresh('governorates'),
        ]);
    }

    public function destroyCountry(Country $country): JsonResponse
    {
        $country->delete();

        return response()->json([
            'message' => 'Country deleted successfully.',
        ]);
    }

    public function updateGovernorate(
        Request $request,
        Governorate $governorate
    ): JsonResponse {
        $data = $request->validate([
            'name_ar' => ['sometimes', 'required', 'string', 'max:255'],
            'name_en' => ['sometimes', 'required', 'string', 'max:255'],
        ]);
        $governorate->update($data);

        return response()->json([
            'message' => 'Governorate updated successfully.',
            'data' => $governorate->fresh(),
        ]);
    }

    public function destroyGovernorate(Governorate $governorate): JsonResponse
    {
        $governorate->delete();

        return response()->json([
            'message' => 'Governorate deleted successfully.',
        ]);
    }
}
