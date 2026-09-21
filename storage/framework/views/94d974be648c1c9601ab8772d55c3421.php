
<?php $__env->startSection('content'); ?>
<div class="py-4">
  <div class="d-flex justify-content-between align-items-center mb-3">
    <div>
      <h1>Medicines</h1>
      <p class="text-muted">Browse medicines available in the selected pharmacy or across the network.</p>
    </div>
    <div>
      <form method="GET" action="<?php echo e(route('medicines.index')); ?>" class="d-flex">
        <input name="q" class="form-control form-control-sm me-2" placeholder="Search name" value="<?php echo e(request('q')); ?>">
        <button class="btn btn-sm btn-outline-secondary">Search</button>
      </form>
    </div>
  </div>

  <div class="row">
    <?php $__empty_1 = true; $__currentLoopData = $medicines; $__env->addLoop($__currentLoopData); foreach($__currentLoopData as $med): $__env->incrementLoopIndices(); $loop = $__env->getLastLoop(); $__empty_1 = false; ?>
      <div class="col-md-3 mb-3">
        <div class="card h-100">
          <div class="card-body d-flex flex-column">
            <h5 class="card-title"><?php echo e($med->name); ?></h5>
            <p class="card-text small text-secondary"><?php echo e($med->category?->name); ?></p>
            <div class="mt-auto d-flex justify-content-between align-items-center">
              <strong>$<?php echo e(number_format($med->price,2)); ?></strong>
              <form method="POST" action="<?php echo e(route('cart.add')); ?>">
                <?php echo csrf_field(); ?>
                <input type="hidden" name="medicine_id" value="<?php echo e($med->id); ?>">
                <input type="number" name="quantity" value="1" min="1" class="form-control form-control-sm d-inline-block me-2" style="width:70px">
                <button class="btn btn-sm btn-primary">Add</button>
              </form>
            </div>
          </div>
        </div>
      </div>
    <?php endforeach; $__env->popLoop(); $loop = $__env->getLastLoop(); if ($__empty_1): ?>
      <div class="col-12"><div class="alert alert-info">No medicines found.</div></div>
    <?php endif; ?>
  </div>
  <?php echo e($medicines->links()); ?>

</div>
<?php $__env->stopSection(); ?>

<?php echo $__env->make('shop.layout', array_diff_key(get_defined_vars(), ['__data' => 1, '__path' => 1]))->render(); ?><?php /**PATH C:\Users\Lenovo\Desktop\Smart Pharmacy System\resources\views\shop\medicines.blade.php ENDPATH**/ ?>