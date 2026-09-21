@extends('shop.layout')
@section('content')
<div class="py-4">
  <h1>Checkout</h1>
  <form method="POST" action="{{ route('checkout.place') }}">
    @csrf
    <div class="mb-3">
      <label class="form-label">Delivery address</label>
      <textarea name="address" class="form-control" rows="3" required></textarea>
    </div>
    <div class="mb-3">
      <p class="text-muted">Payment is mocked for this demo — orders will be created as pending.</p>
    </div>
    <button class="btn btn-primary">Place order</button>
  </form>
</div>
@endsection
