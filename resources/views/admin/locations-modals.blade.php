<div class="modal fade" id="countryModal" tabindex="-1"><div class="modal-dialog"><form class="modal-content" method="POST" action="{{ route('admin.locations.countries.store') }}">
    @csrf <div class="modal-header"><h5 class="modal-title">Add country</h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
    <div class="modal-body">@include('admin.locations-form', ['country' => null])</div>
    <div class="modal-footer"><button type="button" class="btn btn-light" data-bs-dismiss="modal">Cancel</button><button class="btn btn-primary">Save country</button></div>
</form></div></div>
@foreach($countries as $country)
<div class="modal fade" id="editCountry-{{ $country->id }}" tabindex="-1"><div class="modal-dialog"><form class="modal-content" method="POST" action="{{ route('admin.locations.countries.update', $country) }}">
    @csrf @method('PUT') <div class="modal-header"><h5 class="modal-title">Edit country</h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
    <div class="modal-body">@include('admin.locations-form', ['country' => $country])</div>
    <div class="modal-footer"><button type="button" class="btn btn-light" data-bs-dismiss="modal">Cancel</button><button class="btn btn-primary">Save changes</button></div>
</form></div></div>
<div class="modal fade" id="governorate-{{ $country->id }}" tabindex="-1"><div class="modal-dialog"><form class="modal-content" method="POST" action="{{ route('admin.locations.governorates.store', $country) }}">
    @csrf <div class="modal-header"><h5 class="modal-title">Add governorate to {{ $country->name_en }}</h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
    <div class="modal-body">@include('admin.governorate-form', ['governorate' => null])</div>
    <div class="modal-footer"><button type="button" class="btn btn-light" data-bs-dismiss="modal">Cancel</button><button class="btn btn-primary">Add governorate</button></div>
</form></div></div>
@foreach($country->governorates as $governorate)
<div class="modal fade" id="editGovernorate-{{ $governorate->id }}" tabindex="-1"><div class="modal-dialog"><form class="modal-content" method="POST" action="{{ route('admin.locations.governorates.update', $governorate) }}">
    @csrf @method('PUT') <div class="modal-header"><h5 class="modal-title">Edit governorate</h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
    <div class="modal-body">@include('admin.governorate-form', ['governorate' => $governorate])</div>
    <div class="modal-footer"><button type="button" class="btn btn-light" data-bs-dismiss="modal">Cancel</button><button class="btn btn-primary">Save changes</button></div>
</form></div></div>
@endforeach
@endforeach
