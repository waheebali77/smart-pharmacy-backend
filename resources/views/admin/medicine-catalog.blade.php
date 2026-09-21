@extends('admin.layouts.app')

@section('content')
<div class="d-flex flex-wrap align-items-end justify-content-between gap-3 mb-4">
    <div><div class="eyebrow">{{ __('admin.global_templates') }}</div><h1 class="page-title mb-1">{{ __('admin.medicine_catalog') }}</h1><p class="text-secondary mb-0">{{ __('admin.Manage common medicines available as predefined templates for pharmacy owners.') }}</p></div>
    <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#medicineModal"><i class="bi bi-plus-lg me-1"></i>{{ __('admin.add_medicine') }}</button>
</div>

<div class="card p-3 mb-4">
    <form class="row g-2 align-items-end" method="GET" action="{{ route('admin.medicine-catalog') }}">
        <div class="col-lg-4"><label class="form-label small text-secondary">{{ __('admin.search_medicines') }}</label><input class="form-control" name="q" value="{{ request('q') }}" placeholder="{{ __('admin.search_medicines') }}..." /></div>
        <div class="col-md-3 col-lg-2"><label class="form-label small text-secondary">Category</label><select class="form-select" name="category_id"><option value="">All categories</option>@foreach($categories as $category)<option value="{{ $category->id }}" @selected((string) request('category_id') === (string) $category->id)>{{ $category->name }}</option>@endforeach</select></div>
        <div class="col-md-3 col-lg-2"><label class="form-label small text-secondary">Status</label><select class="form-select" name="status"><option value="">All statuses</option><option value="active" @selected(request('status') === 'active')>Active</option><option value="inactive" @selected(request('status') === 'inactive')>Inactive</option></select></div>
        <div class="col-md-3 col-lg-2"><label class="form-label small text-secondary">Prescription</label><select class="form-select" name="prescription"><option value="">All medicines</option><option value="1" @selected(request('prescription') === '1')>Required</option><option value="0" @selected(request('prescription') === '0')>Not required</option></select></div>
        <div class="col-md-auto"><button class="btn btn-outline-secondary"><i class="bi bi-search me-1"></i>Filter</button></div>
    </form>
</div>

<div class="card p-3 p-lg-4">
    <div class="d-flex justify-content-between align-items-center mb-3"><div><h2 class="h5 mb-1">Catalog medicines</h2><div class="small text-secondary">{{ $items->total() }} global templates</div></div><span class="badge bg-light text-dark">Pharmacy inventory is managed separately</span></div>
    <div class="table-responsive"><table class="table align-middle"><thead><tr><th>Image</th><th>Medicine name</th><th>Generic name</th><th>Category</th><th>Strength</th><th>Dosage form</th><th>Prescription</th><th>Status</th><th class="text-end">Actions</th></tr></thead><tbody>
    @forelse($items as $item)
    <tr>
        <td>@if($item->image_path)<img src="{{ url(ltrim($item->image_path, '/')) }}" alt="{{ $item->name }}" class="catalog-thumb">@else<div class="catalog-placeholder"><i class="bi bi-capsule"></i></div>@endif</td>
        <td><strong>{{ $item->name }}</strong><div class="small text-secondary">{{ $item->manufacturer ?: 'Manufacturer not specified' }}</div></td><td>{{ $item->generic_name ?: '—' }}</td><td>{{ $item->category?->name ?: '—' }}</td><td>{{ $item->strength ?: '—' }}</td><td>{{ $item->dosage_form ?: '—' }}</td>
        <td>@if($item->requires_prescription)<span class="badge bg-warning-subtle text-warning-emphasis">Required</span>@else<span class="text-secondary">No</span>@endif</td>
        <td><span class="badge {{ $item->is_available ? 'badge-open' : 'badge-closed' }}">{{ $item->is_available ? 'Active' : 'Inactive' }}</span></td>
        <td class="text-end text-nowrap"><button class="btn btn-sm btn-outline-secondary" data-bs-toggle="modal" data-bs-target="#viewModal{{ $item->id }}" title="View"><i class="bi bi-eye"></i></button> <button class="btn btn-sm btn-outline-primary" data-bs-toggle="modal" data-bs-target="#editMedicine{{ $item->id }}" title="Edit"><i class="bi bi-pencil"></i></button> <form class="d-inline" method="POST" action="{{ route('admin.medicine-catalog.status', $item) }}">@csrf @method('PATCH')<button class="btn btn-sm btn-outline-success" title="Activate or deactivate"><i class="bi bi-power"></i></button></form> <form class="d-inline" method="POST" action="{{ route('admin.medicine-catalog.destroy', $item) }}" onsubmit="return confirm('Delete this catalog medicine? This cannot be undone.')">@csrf @method('DELETE')<button class="btn btn-sm btn-outline-danger" title="Delete"><i class="bi bi-trash"></i></button></form></td>
    </tr>
    <div class="modal fade" id="viewModal{{ $item->id }}" tabindex="-1"><div class="modal-dialog"><div class="modal-content"><div class="modal-header"><h5 class="modal-title">{{ $item->name }}</h5><button class="btn-close" data-bs-dismiss="modal"></button></div><div class="modal-body"><p class="text-secondary">{{ $item->description ?: 'No description provided.' }}</p><dl class="row mb-0"><dt class="col-5">Generic name</dt><dd class="col-7">{{ $item->generic_name ?: '—' }}</dd><dt class="col-5">Manufacturer</dt><dd class="col-7">{{ $item->manufacturer ?: '—' }}</dd><dt class="col-5">Barcode</dt><dd class="col-7">{{ $item->barcode ?: '—' }}</dd><dt class="col-5">Prescription</dt><dd class="col-7">{{ $item->requires_prescription ? 'Required' : 'Not required' }}</dd></dl><div class="alert alert-info mt-3 mb-0 small">This is a global template. It is not pharmacy inventory until an owner adds it.</div></div></div></div></div>
    @empty<tr><td colspan="9" class="text-center text-secondary py-5">No catalog medicines match these filters.</td></tr>@endforelse
    </tbody></table></div>{{ $items->links() }}
</div>

<div class="modal fade" id="medicineModal" tabindex="-1"><div class="modal-dialog modal-lg"><div class="modal-content"><div class="modal-header"><h5 class="modal-title">Add catalog medicine</h5><button class="btn-close" data-bs-dismiss="modal"></button></div><form method="POST" action="{{ route('admin.medicine-catalog.store') }}" enctype="multipart/form-data"><div class="modal-body">@csrf @include('admin.partials.catalog-medicine-fields', ['item' => null])</div><div class="modal-footer"><button type="button" class="btn btn-light" data-bs-dismiss="modal">Cancel</button><button class="btn btn-primary"><i class="bi bi-check2 me-1"></i>Create template</button></div></form></div></div></div>

@foreach($items as $item)
<div class="modal fade" id="editMedicine{{ $item->id }}" tabindex="-1"><div class="modal-dialog modal-lg"><div class="modal-content"><div class="modal-header"><h5 class="modal-title">Edit catalog medicine</h5><button class="btn-close" data-bs-dismiss="modal"></button></div><form method="POST" action="{{ route('admin.medicine-catalog.update', $item) }}" enctype="multipart/form-data"><div class="modal-body">@csrf @method('PATCH') @include('admin.partials.catalog-medicine-fields', ['item' => $item])</div><div class="modal-footer"><button type="button" class="btn btn-light" data-bs-dismiss="modal">Cancel</button><button class="btn btn-primary">Save changes</button></div></form></div></div></div>
@endforeach
@endsection

@push('scripts')
<style>.catalog-thumb,.catalog-placeholder{width:48px;height:48px;border-radius:10px;object-fit:cover}.catalog-placeholder{display:grid;place-items:center;background:var(--mint);color:var(--teal);font-size:1.25rem}.table td{min-width:90px}</style>
@endpush
