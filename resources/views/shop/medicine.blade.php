@extends('shop.layout')
@section('content')
<div class="py-4">
  <a href="{{ url()->previous() }}" class="btn btn-link mb-3">&larr; Back</a>
  <div class="card p-4">
    <h2>{{ $medicine->name }}</h2>
    <p class="text-secondary">{{ $medicine->category?->name }}</p>
    <p>{{ $medicine->description }}</p>
    <p><strong>Price:</strong> ${{ number_format($medicine->price,2) }}</p>
    <p><strong>Available:</strong> {{ $available ? 'Yes' : 'No' }}</p>

    <div class="d-flex gap-2 mt-3">
      <a href="{{ route('shop.search', ['q' => request('q')]) }}" class="btn btn-outline-secondary">Cancel</a>
      @if($available)
        <form method="POST" action="{{ route('cart.add') }}">
          @csrf
          <input type="hidden" name="medicine_id" value="{{ $medicine->id }}">
          <input type="number" name="quantity" value="1" min="1" class="form-control d-inline-block" style="width:100px">
          <button class="btn btn-primary">Add</button>
        </form>
      @else
        <form method="POST" action="{{ route('shop.request') }}">
          @csrf
          <input type="hidden" name="type" value="medicine">
          <input type="hidden" name="id" value="{{ $medicine->id }}">
          <button class="btn btn-primary">Request</button>
        </form>
      @endif
    </div>
  </div>
</div>
@endsection
