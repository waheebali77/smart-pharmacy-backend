@extends('shop.layout')
@section('content')
<div class="py-4">
  <a href="{{ url()->previous() }}" class="btn btn-link mb-3">&larr; Back</a>
  <div class="card p-4">
    <h2>{{ $offer->title }}</h2>
    <p class="text-secondary">{{ $pharmacy?->name }}</p>
    <p>{{ $offer->description }}</p>
    <p><strong>Discount:</strong> {{ $offer->discount_percentage }}%</p>
    <div class="d-flex gap-2 mt-3">
      <a href="{{ route('shop.search', ['q' => request('q')]) }}" class="btn btn-outline-secondary">Cancel</a>
      <form method="POST" action="{{ route('shop.request') }}">
        @csrf
        <input type="hidden" name="type" value="offer">
        <input type="hidden" name="id" value="{{ $offer->id }}">
        <button class="btn btn-primary">Request</button>
      </form>
    </div>
  </div>
</div>
@endsection
