@extends('shop.layout')
@section('content')
<div class="py-4">
  <h1>Your cart</h1>
  @php $items = $cart['items'] ?? []; @endphp
  @if(empty($items))
    <div class="alert alert-info">Your cart is empty. Browse <a href="{{ route('medicines.index') }}">medicines</a>.</div>
  @else
    <div class="card p-3 mb-3">
      <table class="table mb-0">
        <thead><tr><th>Item</th><th>Price</th><th>Qty</th><th>Subtotal</th></tr></thead>
        <tbody>
        @php $total = 0; @endphp
        @foreach($items as $it)
          @php $subtotal = $it['price'] * $it['quantity']; $total += $subtotal; @endphp
          <tr><td>{{ $it['name'] }}</td><td>${{ number_format($it['price'],2) }}</td><td>{{ $it['quantity'] }}</td><td>${{ number_format($subtotal,2) }}</td></tr>
        @endforeach
        </tbody>
      </table>
    </div>
    <div class="d-flex justify-content-between align-items-center">
      <div><a href="{{ route('medicines.index') }}" class="btn btn-outline-secondary">Continue shopping</a></div>
      <div>
        <strong class="me-3">Total: ${{ number_format($total,2) }}</strong>
        <a href="{{ route('checkout.index') }}" class="btn btn-primary">Checkout</a>
      </div>
    </div>
  @endif
</div>
@endsection
