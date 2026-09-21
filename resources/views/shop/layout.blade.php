<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>{{ $title ?? 'Shop' }} | Smart Pharmacy</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
  <style>body{padding-top:70px}</style>
</head>
<body>
  <nav class="navbar navbar-expand-lg navbar-light bg-light fixed-top">
    <div class="container">
      <a class="navbar-brand" href="/">Smart Pharmacy</a>
      <div class="collapse navbar-collapse">
        <ul class="navbar-nav ms-auto">
          <li class="nav-item"><a class="nav-link" href="{{ route('offers.index') }}">Offers</a></li>
          <li class="nav-item"><a class="nav-link" href="{{ route('medicines.index') }}">Medicines</a></li>
          <li class="nav-item"><a class="nav-link" href="{{ route('cart.index') }}">Cart <span class="badge bg-secondary">{{ session('cart.items') ? count(session('cart.items')) : 0 }}</span></a></li>
            <li class="nav-item"><a class="nav-link" href="{{ route('admin.login') }}">Admin</a></li>
        </ul>
      </div>
    </div>
  </nav>

  <main class="container">
    @if(session('success'))<div class="alert alert-success">{{ session('success') }}</div>@endif
    @if(session('error'))<div class="alert alert-danger">{{ session('error') }}</div>@endif
    @yield('content')
  </main>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
  <script>
    document.addEventListener('DOMContentLoaded', function() {
      // Initialize carousel with auto-rotation
      var carousel = new bootstrap.Carousel(document.getElementById('offersCarousel'), {
        interval: 5000,
        wrap: true
      });
      
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
</body>
</html>
