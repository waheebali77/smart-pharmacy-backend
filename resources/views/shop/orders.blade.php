@extends('shop.layout')
@section('content')
<div class="py-4">
  <h1>Your orders</h1>
  @forelse($items as $order)
    <div class="card mb-3 p-3">
      <div class="d-flex justify-content-between">
        <div>
          <strong>Order #{{ $order->id }}</strong>
          <div class="small text-secondary">Status: {{ ucfirst($order->status) }}</div>
        </div>
        <div>
          <div class="small text-secondary">Total: ${{ number_format($order->total_price,2) }}</div>
          <div class="small text-secondary">Placed: {{ $order->created_at->format('d M Y, H:i') }}</div>
        </div>
      </div>
      @if($order->items->isNotEmpty())
        <hr>
        <ul class="mb-0">
          @foreach($order->items as $it)
            <li>{{ $it->medicine?->name }} — {{ $it->quantity }} x ${{ number_format($it->price,2) }}</li>
          @endforeach
        </ul>
      @endif
    </div>
  @empty
    <div class="alert alert-info">You have not placed any orders yet.</div>
  @endforelse

  {{ $items->links() }}
</div>
@endsection
