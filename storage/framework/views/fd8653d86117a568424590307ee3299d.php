<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title><?php echo e($title ?? 'Shop'); ?> | Smart Pharmacy</title>
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
          <li class="nav-item"><a class="nav-link" href="<?php echo e(route('offers.index')); ?>">Offers</a></li>
          <li class="nav-item"><a class="nav-link" href="<?php echo e(route('medicines.index')); ?>">Medicines</a></li>
          <li class="nav-item"><a class="nav-link" href="<?php echo e(route('cart.index')); ?>">Cart <span class="badge bg-secondary"><?php echo e(session('cart.items') ? count(session('cart.items')) : 0); ?></span></a></li>
            <li class="nav-item"><a class="nav-link" href="<?php echo e(route('admin.login')); ?>">Admin</a></li>
        </ul>
      </div>
    </div>
  </nav>

  <main class="container">
    <?php if(session('success')): ?><div class="alert alert-success"><?php echo e(session('success')); ?></div><?php endif; ?>
    <?php if(session('error')): ?><div class="alert alert-danger"><?php echo e(session('error')); ?></div><?php endif; ?>
    <?php echo $__env->yieldContent('content'); ?>
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
<?php /**PATH C:\Users\Lenovo\Desktop\Smart Pharmacy System\resources\views\shop\layout.blade.php ENDPATH**/ ?>