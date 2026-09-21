
<?php $__env->startSection('content'); ?>
<div class="py-4">
  <h1>Active Offers</h1>
  <p class="text-muted">Browse current promotions across nearby pharmacies.</p>
  <div class="row">
    <?php $__empty_1 = true; $__currentLoopData = $offers; $__env->addLoop($__currentLoopData); foreach($__currentLoopData as $offer): $__env->incrementLoopIndices(); $loop = $__env->getLastLoop(); $__empty_1 = false; ?>
      <div class="col-md-4 mb-3">
        <div class="card h-100">
          <div class="card-body d-flex flex-column">
            <h5 class="card-title"><?php echo e($offer->title); ?></h5>
            <p class="card-text text-muted"><?php echo e(Str::limit($offer->description, 120)); ?></p>
            <div class="mt-auto d-flex justify-content-between align-items-center">
              <small class="text-secondary"><?php echo e($offer->pharmacy?->name); ?></small>
              <a href="<?php echo e(route('medicines.index', ['pharmacy' => $offer->pharmacy_id])); ?>" class="btn btn-primary btn-sm">Shop with Offer</a>
            </div>
          </div>
        </div>
      </div>
    <?php endforeach; $__env->popLoop(); $loop = $__env->getLastLoop(); if ($__empty_1): ?>
      <div class="col-12"><div class="alert alert-info">No active offers at the moment.</div></div>
    <?php endif; ?>
  </div>
  <?php echo e($offers->links()); ?>

</div>
<?php $__env->stopSection(); ?>

<?php echo $__env->make('shop.layout', array_diff_key(get_defined_vars(), ['__data' => 1, '__path' => 1]))->render(); ?><?php /**PATH C:\Users\Lenovo\Desktop\Smart Pharmacy System\resources\views\shop\offers.blade.php ENDPATH**/ ?>