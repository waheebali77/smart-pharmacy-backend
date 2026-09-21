

<?php $__env->startSection('content'); ?>
<!-- Greeting Banner -->
<div class="bg-primary text-white py-4 px-3 rounded mb-4 d-flex justify-content-between align-items-center">
    <div>
        <h2 class="mb-1">Welcome back, <?php echo e(Auth::check() ? Auth::user()->name : 'Guest'); ?>!</h2>
        <p class="mb-0">Your health is our priority</p>
    </div>
    <div class="position-relative">
        <button class="btn btn-light position-relative" onclick="window.location.href='<?php echo e(route("shop.orders")); ?>'">
            <i class="bi bi-bell fs-4"></i>
            <?php if(Auth::check() && Auth::user()->unreadNotificationsCount > 0): ?>
                <span class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger">
                    <?php echo e(Auth::user()->unreadNotificationsCount); ?>

                </span>
            <?php endif; ?>
        </button>
    </div>
</div>

<!-- Featured Offers Slider -->
<div class="mb-5">
    <h3 class="mb-3">Featured Offers</h3>
    <div id="offersCarousel" class="carousel slide" data-bs-ride="carousel">
        <div class="carousel-indicators">
            <?php $__empty_1 = true; $__currentLoopData = $offers; $__env->addLoop($__currentLoopData); foreach($__currentLoopData as $key => $offer): $__env->incrementLoopIndices(); $loop = $__env->getLastLoop(); $__empty_1 = false; ?>
                <button type="button" data-bs-target="#offersCarousel" data-bs-slide-to="<?php echo e($key); ?>" <?php echo e($key == 0 ? 'class="active"' : ''); ?>></button>
            <?php endforeach; $__env->popLoop(); $loop = $__env->getLastLoop(); if ($__empty_1): ?>
                <button type="button" data-bs-target="#offersCarousel" data-bs-slide-to="0" class="active"></button>
            <?php endif; ?>
        </div>
        <div class="carousel-inner rounded">
            <?php $__empty_1 = true; $__currentLoopData = $offers; $__env->addLoop($__currentLoopData); foreach($__currentLoopData as $key => $offer): $__env->incrementLoopIndices(); $loop = $__env->getLastLoop(); $__empty_1 = false; ?>
                <div class="carousel-item <?php echo e($key == 0 ? 'active' : ''); ?>">
                    <div class="card bg-light">
                        <div class="row g-0">
                            <div class="col-md-4">
                                <img src="https://picsum.photos/seed/offer<?php echo e($offer->id); ?>/600/400.jpg" class="img-fluid rounded-start h-100 object-fit-cover" alt="<?php echo e($offer->title); ?>">
                            </div>
                            <div class="col-md-8">
                                <div class="card-body">
                                    <h5 class="card-title"><?php echo e($offer->title); ?></h5>
                                    <p class="card-text"><?php echo e(Str::limit($offer->description, 150)); ?></p>
                                    <p class="card-text">
                                        <small class="text-muted">Offered by: <?php echo e($offer->pharmacy->name); ?></small>
                                    </p>
                                    <div class="d-flex justify-content-between align-items-center">
                                        <a href="<?php echo e(route('offers.show', $offer)); ?>" class="btn btn-primary">View Details</a>
                                        <span class="badge bg-success"><?php echo e($offer->discount); ?>% OFF</span>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            <?php endforeach; $__env->popLoop(); $loop = $__env->getLastLoop(); if ($__empty_1): ?>
                <div class="carousel-item active">
                    <div class="card bg-light">
                        <div class="card-body text-center py-5">
                            <h5 class="card-title">No Offers Available</h5>
                            <p class="card-text">Check back later for exciting deals and discounts!</p>
                        </div>
                    </div>
                </div>
            <?php endif; ?>
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
        <?php $__empty_1 = true; $__currentLoopData = $pharmacies; $__env->addLoop($__currentLoopData); foreach($__currentLoopData as $pharmacy): $__env->incrementLoopIndices(); $loop = $__env->getLastLoop(); $__empty_1 = false; ?>
            <div class="col-md-4 mb-3">
                <div class="card h-100">
                    <div class="card-body">
                        <div class="d-flex justify-content-between align-items-start mb-2">
                            <h5 class="card-title"><?php echo e($pharmacy->name); ?></h5>
                            <span class="badge bg-primary"><?php echo e(number_format($pharmacy->distance, 1)); ?> km</span>
                        </div>
                        <p class="card-text small text-secondary"><?php echo e($pharmacy->address); ?></p>
                        <div class="d-flex justify-content-between align-items-center">
                            <div>
                                <span class="text-warning">
                                    <?php for($i = 1; $i <= 5; $i++): ?>
                                        <?php if($i <= round($pharmacy->rating)): ?>
                                            <i class="bi bi-star-fill"></i>
                                        <?php else: ?>
                                            <i class="bi bi-star"></i>
                                        <?php endif; ?>
                                    <?php endfor; ?>
                                </span>
                                <small class="text-muted">(<?php echo e(number_format($pharmacy->rating, 1)); ?>)</small>
                            </div>
                            <a href="#" class="btn btn-sm btn-outline-primary">View</a>
                        </div>
                    </div>
                </div>
            </div>
        <?php endforeach; $__env->popLoop(); $loop = $__env->getLastLoop(); if ($__empty_1): ?>
            <div class="col-12">
                <div class="alert alert-info">No nearby pharmacies found.</div>
            </div>
        <?php endif; ?>
    </div>
</div>

<!-- Interactive Category Icons -->
<div class="mb-5">
    <h3 class="mb-3">Shop by Category</h3>
    <div class="row">
        <?php $__empty_1 = true; $__currentLoopData = $categories; $__env->addLoop($__currentLoopData); foreach($__currentLoopData as $category): $__env->incrementLoopIndices(); $loop = $__env->getLastLoop(); $__empty_1 = false; ?>
            <div class="col-md-2 mb-3">
                <div class="card text-center category-card" data-category="<?php echo e($category->id); ?>">
                    <div class="card-body">
                        <i class="bi bi-capsule fs-1 text-primary mb-2"></i>
                        <h6 class="card-title"><?php echo e($category->name); ?></h6>
                    </div>
                </div>
            </div>
        <?php endforeach; $__env->popLoop(); $loop = $__env->getLastLoop(); if ($__empty_1): ?>
            <div class="col-12">
                <div class="alert alert-info">No categories available.</div>
            </div>
        <?php endif; ?>
    </div>
</div>

<!-- Popular Medicines Section -->
<div class="mb-5">
    <h3 class="mb-3">Popular Medicines</h3>
    <div class="row">
        <?php $__empty_1 = true; $__currentLoopData = $medicines; $__env->addLoop($__currentLoopData); foreach($__currentLoopData as $medicine): $__env->incrementLoopIndices(); $loop = $__env->getLastLoop(); $__empty_1 = false; ?>
            <div class="col-md-3 mb-3">
                <div class="card h-100">
                    <div class="card-body d-flex flex-column">
                        <h5 class="card-title"><?php echo e($medicine->name); ?></h5>
                        <p class="card-text small text-secondary"><?php echo e($medicine->category?->name); ?></p>
                        <div class="mt-auto d-flex justify-content-between align-items-center">
                            <strong>$<?php echo e(number_format($medicine->price,2)); ?></strong>
                            <form method="POST" action="<?php echo e(route('cart.add')); ?>" class="d-flex">
                                <?php echo csrf_field(); ?>
                                <input type="hidden" name="medicine_id" value="<?php echo e($medicine->id); ?>">
                                <button type="submit" class="btn btn-sm btn-primary">Add</button>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        <?php endforeach; $__env->popLoop(); $loop = $__env->getLastLoop(); if ($__empty_1): ?>
            <div class="col-12">
                <div class="alert alert-info">No medicines found.</div>
            </div>
        <?php endif; ?>
    </div>
</div>

<!-- Floating Cart Button -->
<div class="position-fixed bottom-0 end-0 p-3" style="z-index: 11">
    <div class="d-flex flex-column align-items-end">
        <a href="<?php echo e(route('cart.index')); ?>" class="btn btn-primary btn-lg rounded-circle mb-2 position-relative" style="width: 60px; height: 60px;">
            <i class="bi bi-cart3 fs-4"></i>
            <?php if(session('cart.items') && count(session('cart.items')) > 0): ?>
                <span class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger">
                    <?php echo e(count(session('cart.items'))); ?>

                </span>
            <?php endif; ?>
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
<?php $__env->stopSection(); ?>
<?php echo $__env->make('shop.layout', array_diff_key(get_defined_vars(), ['__data' => 1, '__path' => 1]))->render(); ?><?php /**PATH C:\Users\Lenovo\Desktop\Smart Pharmacy System\resources\views\shop\home.blade.php ENDPATH**/ ?>