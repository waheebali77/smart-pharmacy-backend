@extends('shop.layout')
@section('content')
<div class="py-4">
  <div class="d-flex justify-content-between align-items-center mb-3">
    <div>
      <h1>Medicines</h1>
      <p class="text-muted">Browse medicines available in the selected pharmacy or across the network.</p>
    </div>
    <div>
      <form method="GET" action="{{ route('medicines.index') }}" class="d-flex">
        <input name="q" class="form-control form-control-sm me-2" placeholder="Search name" value="{{ request('q') }}">
        <button class="btn btn-sm btn-outline-secondary">Search</button>
      </form>
    </div>
  </div>

  <div class="row">
    @forelse($medicines as $med)
      <div class="col-md-3 mb-3">
        <div class="card h-100">
          <div class="card-body d-flex flex-column">
            <h5 class="card-title">{{ $med->name }}</h5>
            <p class="card-text small text-secondary">{{ $med->category?->name }}</p>
            <div class="mt-auto d-flex justify-content-between align-items-center">
              <strong>${{ number_format($med->price,2) }}</strong>
              <form method="POST" action="{{ route('cart.add') }}">
                @csrf
                <input type="hidden" name="medicine_id" value="{{ $med->id }}">
                <input type="number" name="quantity" value="1" min="1" class="form-control form-control-sm d-inline-block me-2" style="width:70px">
                <button class="btn btn-sm btn-primary">Add</button>
              </form>
            </div>
          </div>
        </div>
      </div>
    @empty
      <div class="col-12"><div class="alert alert-info">No medicines found.</div></div>
    @endforelse
  </div>
  {{ $medicines->links() }}
</div>
@endsection
