@extends('shop.layout')
@section('content')
<div class="py-4">
  <h1>Active Offers</h1>
  <p class="text-muted">Browse current promotions across nearby pharmacies.</p>
  <div class="row">
    @forelse($offers as $offer)
      <div class="col-md-4 mb-3">
        <div class="card h-100">
          <div class="card-body d-flex flex-column">
            <h5 class="card-title">{{ $offer->title }}</h5>
            <p class="card-text text-muted">{{ Str::limit($offer->description, 120) }}</p>
            <div class="mt-auto d-flex justify-content-between align-items-center">
              <small class="text-secondary">{{ $offer->pharmacy?->name }}</small>
              <a href="{{ route('medicines.index', ['pharmacy' => $offer->pharmacy_id]) }}" class="btn btn-primary btn-sm">Shop with Offer</a>
            </div>
          </div>
        </div>
      </div>
    @empty
      <div class="col-12"><div class="alert alert-info">No active offers at the moment.</div></div>
    @endforelse
  </div>
  {{ $offers->links() }}
</div>
@endsection
