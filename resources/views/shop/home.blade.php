@extends('shop.layout')

@section('content')
<!-- Greeting Banner -->
<div class="bg-primary text-white py-4 px-3 rounded mb-4 d-flex justify-content-between align-items-center">
    <div>
        <h2 class="mb-1">Welcome back, {{ Auth::check() ? Auth::user()->name : 'Guest' }}!</h2>
        <p class="mb-0">Your health is our priority</p>
    </div>
    <div class="position-relative">
        <button class="btn btn-light position-relative" onclick="window.location.href='{{ route("shop.orders") }}'">
            <i class="bi bi-bell fs-4"></i>
            @if(Auth::check() && Auth::user()->unreadNotificationsCount > 0)
                <span class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger">
                    {{ Auth::user()->unreadNotificationsCount }}
                </span>
            @endif
        </button>
    </div>
</div>

<!-- Featured Offers Slider -->
<div class="mb-5">
    <h3 class="mb-3">Featured Offers</h3>
    <div id="offersCarousel" class="carousel slide" data-bs-ride="carousel">
        <div class="carousel-indicators">
            @forelse($offers as $key => $offer)
                <button type="button" data-bs-target="#offersCarousel" data-bs-slide-to="{{ $key }}" {{ $key == 0 ? 'class="active"' : '' }}></button>
            @empty
                <button type="button" data-bs-target="#offersCarousel" data-bs-slide-to="0" class="active"></button>
            @endforelse
        </div>
        <div class="carousel-inner rounded">
            @forelse($offers as $key => $offer)
                <div class="carousel-item {{ $key == 0 ? 'active' : '' }}">
                    <div class="card bg-light">
                        <div class="row g-0">
                            <div class="col-md-4">
                                <img src="https://picsum.photos/seed/offer{{ $offer->id }}/600/400.jpg" class="img-fluid rounded-start h-100 object-fit-cover" alt="{{ $offer->title }}">
                            </div>
                            <div class="col-md-8">
                                <div class="card-body">
                                    <h5 class="card-title">{{ $offer->title }}</h5>
                                    <p class="card-text">{{ Str::limit($offer->description, 150) }}</p>
                                    <p class="card-text">
                                        <small class="text-muted">Offered by: {{ $offer->pharmacy->name }}</small>
                                    </p>
                                    <div class="d-flex justify-content-between align-items-center">
                                        <a href="{{ route('offers.show', $offer) }}" class="btn btn-primary">View Details</a>
                                        <span class="badge bg-success">{{ $offer->discount }}% OFF</span>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            @empty
                <div class="carousel-item active">
                    <div class="card bg-light">
                        <div class="card-body text-center py-5">
                            <h5 class="card-title">No Offers Available</h5>
                            <p class="card-text">Check back later for exciting deals and discounts!</p>
                        </div>
                    </div>
                </div>
            @endforelse
        </div>
        <button class="carousel-control-prev" type="button" data-bs-target="#offersCarousel" data-bs-slide="prev">
            <span class="carousel-control-prev-icon" aria-hidden="true"></span>
            <span class="visually-hidden">Previous</span>
        </button>
        <button class="carousel-control-next" type="button" data-bs-target="#offersCarousel" data-bs-slide="next">
            <span class="carousel-control-next-icon" aria-hidden="true"></span>
            <span class="visually-hidden">Next</span>
        </button>
    </div>
</div>

<!-- Nearby Pharmacies Section -->
<div class="mb-5">
    <h3 class="mb-3">Nearby Pharmacies</h3>
    <div class="row">
        @forelse($pharmacies as $pharmacy)
            <div class="col-md-4 mb-3">
                <div class="card h-100">
                    <div class="card-body">
                        <div class="d-flex justify-content-between align-items-start mb-2">
                            <h5 class="card-title">{{ $pharmacy->name }}</h5>
                            <span class="badge bg-primary">{{ number_format($pharmacy->distance, 1) }} km</span>
                        </div>
                        <p class="card-text small text-secondary">{{ $pharmacy->address }}</p>
                        <div class="d-flex justify-content-between align-items-center">
                            <div>
                                <span class="text-warning">
                                    @for($i = 1; $i <= 5; $i++)
                                        @if($i <= round($pharmacy->rating))
                                            <i class="bi bi-star-fill"></i>
                                        @else
                                            <i class="bi bi-star"></i>
                                        @endif
                                    @endfor
                                </span>
                                <small class="text-muted">({{ number_format($pharmacy->rating, 1) }})</small>
                            </div>
                            <a href="#" class="btn btn-sm btn-outline-primary">View</a>
                        </div>
                    </div>
                </div>
            </div>
        @empty
            <div class="col-12">
                <div class="alert alert-info">No nearby pharmacies found.</div>
            </div>
        @endforelse
    </div>
</div>

<!-- Interactive Category Icons -->
<div class="mb-5">
    <h3 class="mb-3">Shop by Category</h3>
    <div class="row">
        @forelse($categories as $category)
            <div class="col-md-2 mb-3">
                <div class="card text-center category-card" data-category="{{ $category->id }}">
                    <div class="card-body">
                        <i class="bi bi-capsule fs-1 text-primary mb-2"></i>
                        <h6 class="card-title">{{ $category->name }}</h6>
                    </div>
                </div>
            </div>
        @empty
            <div class="col-12">
                <div class="alert alert-info">No categories available.</div>
            </div>
        @endforelse
    </div>
</div>

<!-- Popular Medicines Section -->
<div class="mb-5">
    <h3 class="mb-3">Popular Medicines</h3>
    <div class="row">
        @forelse($medicines as $medicine)
            <div class="col-md-3 mb-3">
                <div class="card h-100">
                    <div class="card-body d-flex flex-column">
                        <h5 class="card-title">{{ $medicine->name }}</h5>
                        <p class="card-text small text-secondary">{{ $medicine->category?->name }}</p>
                        <div class="mt-auto d-flex justify-content-between align-items-center">
                            <strong>${{ number_format($medicine->price,2) }}</strong>
                            <form method="POST" action="{{ route('cart.add') }}" class="d-flex">
                                @csrf
                                <input type="hidden" name="medicine_id" value="{{ $medicine->id }}">
                                <button type="submit" class="btn btn-sm btn-primary">Add</button>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        @empty
            <div class="col-12">
                <div class="alert alert-info">No medicines found.</div>
            </div>
        @endforelse
    </div>
</div>

<!-- Floating Cart Button -->
<div class="position-fixed bottom-0 end-0 p-3" style="z-index: 11">
    <div class="d-flex flex-column align-items-end">
        <a href="{{ route('cart.index') }}" class="btn btn-primary btn-lg rounded-circle mb-2 position-relative" style="width: 60px; height: 60px;">
            <i class="bi bi-cart3 fs-4"></i>
            @if(session('cart.items') && count(session('cart.items')) > 0)
                <span class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger">
                    {{ count(session('cart.items')) }}
                </span>
            @endif
        </a>
        <small class="text-muted">View Cart</small>
    </div>
</div>

<style>
.category-card {
    cursor: pointer;
    transition: transform 0.2s;
}

.category-card:hover {
    transform: translateY(-5px);
    box-shadow: 0 4px 8px rgba(0,0,0,0.1);
}

.carousel-inner {
    height: 400px;
}

.carousel-item img {
    height: 100%;
    object-fit: cover;
}
</style>

<script>
document.addEventListener('DOMContentLoaded', function() {
    // Category click handler
    const categoryCards = document.querySelectorAll('.category-card');
    categoryCards.forEach(card => {
        card.addEventListener('click', function() {
            const categoryId = this.dataset.category;
            window.location.href = `/medicines?category=${categoryId}`;
        });
    });
});
</script>
@endsection