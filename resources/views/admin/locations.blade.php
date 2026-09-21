@extends('admin.layouts.app')

@section('content')
<div class="d-flex flex-wrap justify-content-between align-items-end gap-3 mb-4">
    <div>
        <div class="eyebrow">Location management</div>
        <h1 class="page-title mb-1">Countries & governorates</h1>
        <p class="text-secondary mb-0">Manage the locations shown during mobile app onboarding.</p>
    </div>
    <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#countryModal">
        <i class="bi bi-plus-lg me-1"></i>Add country
    </button>
</div>

<div class="row g-4">
    <div class="col-lg-5">
        <div class="card h-100">
            <div class="card-body p-0">
                <div class="p-4 border-bottom">
                    <h5 class="mb-1">Countries</h5>
                    <div class="small text-secondary">{{ $countries->count() }} countries configured</div>
                </div>
                <div class="list-group list-group-flush">
                    @forelse($countries as $country)
                        <button class="list-group-item list-group-item-action country-row d-flex align-items-center justify-content-between p-3"
                                data-country="{{ $country->id }}">
                            <span>
                                <strong>{{ $country->name_en }}</strong>
                                <span class="text-secondary small d-block">{{ $country->name_ar }} · {{ $country->code }}</span>
                            </span>
                            <span class="badge rounded-pill text-bg-light">{{ $country->governorates->count() }}</span>
                        </button>
                    @empty
                        <div class="p-4 text-secondary">No countries yet. Add the first country to get started.</div>
                    @endforelse
                </div>
            </div>
        </div>
    </div>

    <div class="col-lg-7">
        @foreach($countries as $country)
            <section class="card country-panel" id="country-panel-{{ $country->id }}" hidden>
                <div class="card-body">
                    <div class="d-flex justify-content-between align-items-start gap-3 mb-4">
                        <div>
                            <div class="eyebrow">{{ $country->code }}</div>
                            <h4 class="mb-1">{{ $country->name_en }}</h4>
                            <div class="text-secondary">{{ $country->name_ar }}</div>
                        </div>
                        <div class="d-flex gap-2">
                            <button class="btn btn-sm btn-outline-secondary" data-bs-toggle="modal" data-bs-target="#editCountry-{{ $country->id }}"><i class="bi bi-pencil"></i></button>
                            <form method="POST" action="{{ route('admin.locations.countries.destroy', $country) }}" onsubmit="return confirm('Delete this country and all its governorates?')">
                                @csrf @method('DELETE')
                                <button class="btn btn-sm btn-outline-danger"><i class="bi bi-trash"></i></button>
                            </form>
                        </div>
                    </div>
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h6 class="mb-0">Governorates</h6>
                        <button class="btn btn-sm btn-primary" data-bs-toggle="modal" data-bs-target="#governorate-{{ $country->id }}"><i class="bi bi-plus-lg me-1"></i>Add</button>
                    </div>
                    <div class="table-responsive">
                        <table class="table align-middle mb-0">
                            <thead><tr><th>Arabic name</th><th>English name</th><th class="text-end">Actions</th></tr></thead>
                            <tbody>
                            @forelse($country->governorates as $governorate)
                                <tr>
                                    <td>{{ $governorate->name_ar }}</td><td>{{ $governorate->name_en }}</td>
                                    <td class="text-end text-nowrap">
                                        <button class="btn btn-sm btn-link text-secondary" data-bs-toggle="modal" data-bs-target="#editGovernorate-{{ $governorate->id }}"><i class="bi bi-pencil"></i></button>
                                        <form class="d-inline" method="POST" action="{{ route('admin.locations.governorates.destroy', $governorate) }}" onsubmit="return confirm('Delete this governorate?')">
                                            @csrf @method('DELETE')<button class="btn btn-sm btn-link text-danger"><i class="bi bi-trash"></i></button>
                                        </form>
                                    </td>
                                </tr>
                            @empty
                                <tr><td colspan="3" class="text-secondary py-4">No governorates configured.</td></tr>
                            @endforelse
                            </tbody>
                        </table>
                    </div>
                </div>
            </section>
        @endforeach
        <div id="empty-location-state" class="card"><div class="card-body text-center text-secondary py-5"><i class="bi bi-globe2 fs-1 d-block mb-3"></i>Select a country to manage its governorates.</div></div>
    </div>
</div>

@include('admin.locations-modals')
@endsection

@push('scripts')
<script>
document.addEventListener('DOMContentLoaded', function () {
    const rows = document.querySelectorAll('.country-row');
    const panels = document.querySelectorAll('.country-panel');
    const empty = document.getElementById('empty-location-state');
    function show(id) {
        panels.forEach(panel => panel.hidden = panel.id !== `country-panel-${id}`);
        empty.hidden = Boolean(id);
        rows.forEach(row => row.classList.toggle('active', row.dataset.country === String(id)));
    }
    rows.forEach(row => row.addEventListener('click', () => show(row.dataset.country)));
    if (rows.length) show(rows[0].dataset.country);
});
</script>
@endpush
