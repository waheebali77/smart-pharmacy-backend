@extends('shop.layout')
@section('content')
<div class="py-4">
  <h1>Search</h1>
  <form method="GET" action="{{ route('shop.search') }}" class="mb-3">
    <div class="input-group">
      <input name="q" class="form-control" placeholder="Search medicines, pharmacies, offers" value="{{ $q ?? '' }}">
      <button class="btn btn-outline-secondary">Search</button>
    </div>
  </form>

  @if(empty($q))
    <div class="text-center text-muted py-5">
      <i class="bi bi-search" style="font-size:40px"></i>
      <p class="mt-3">Search for medicines, pharmacies, or offers to filter results.</p>
    </div>
  @else
    <div class="row">
      <div class="col-md-6">
        <h4>Medicines</h4>
        @forelse($medicines as $m)
          <div class="card mb-2">
            <div class="card-body position-relative py-2">
              <div class="d-flex justify-content-between align-items-center">
                <div>
                  <strong>{{ $m->name }}</strong>
                  <div class="small text-secondary">{{ $m->category?->name }}</div>
                </div>
                <div class="text-end"><i class="bi bi-chevron-right"></i></div>
              </div>
              <a href="{{ route('medicines.show', $m) }}" class="stretched-link" aria-label="View {{ $m->name }} details"></a>
            </div>
          </div>
        @empty
          <div class="text-muted">No medicines match.</div>
        @endforelse
      </div>
      <div class="col-md-6">
        <h4>Offers</h4>
        @forelse($offers as $o)
          <div class="card mb-2">
            <div class="card-body position-relative py-2">
              <div class="d-flex justify-content-between align-items-center">
                <div>
                  <strong>{{ $o->title }}</strong>
                  <div class="small text-secondary">{{ $o->pharmacy?->name }}</div>
                </div>
                <div><i class="bi bi-chevron-right"></i></div>
              </div>
              <a href="{{ route('offers.show', $o) }}" class="stretched-link" aria-label="View {{ $o->title }} details"></a>
            </div>
          </div>
        @empty
          <div class="text-muted">No offers match.</div>
        @endforelse

        <h4 class="mt-4">Pharmacies</h4>
        @forelse($pharmacies as $p)
          <div class="card mb-2 p-2 d-flex justify-content-between align-items-center">
            <div>
              <strong>{{ $p->name }}</strong><div class="small text-secondary">{{ Str::limit($p->address,60) }}</div>
            </div>
            <div>
              <form method="POST" action="{{ route('shop.request') }}">
                @csrf
                <input type="hidden" name="type" value="pharmacy">
                <input type="hidden" name="id" value="{{ $p->id }}">
                <button class="btn btn-sm btn-outline-secondary">Request</button>
              </form>
            </div>
          </div>
        @empty
          <div class="text-muted">No pharmacies match.</div>
        @endforelse
      </div>
    </div>
  @endif
</div>
@endsection
