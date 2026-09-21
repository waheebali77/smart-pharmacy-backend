
<?php $__env->startSection('content'); ?>
<div class="py-4">
  <h1>Search</h1>
  <form method="GET" action="<?php echo e(route('shop.search')); ?>" class="mb-3">
    <div class="input-group">
      <input name="q" class="form-control" placeholder="Search medicines, pharmacies, offers" value="<?php echo e($q ?? ''); ?>">
      <button class="btn btn-outline-secondary">Search</button>
    </div>
  </form>

  <?php if(empty($q)): ?>
    <div class="text-center text-muted py-5">
      <i class="bi bi-search" style="font-size:40px"></i>
      <p class="mt-3">Search for medicines, pharmacies, or offers to filter results.</p>
    </div>
  <?php else: ?>
    <div class="row">
      <div class="col-md-6">
        <h4>Medicines</h4>
        <?php $__empty_1 = true; $__currentLoopData = $medicines; $__env->addLoop($__currentLoopData); foreach($__currentLoopData as $m): $__env->incrementLoopIndices(); $loop = $__env->getLastLoop(); $__empty_1 = false; ?>
          <div class="card mb-2">
            <div class="card-body position-relative py-2">
              <div class="d-flex justify-content-between align-items-center">
                <div>
                  <strong><?php echo e($m->name); ?></strong>
                  <div class="small text-secondary"><?php echo e($m->category?->name); ?></div>
                </div>
                <div class="text-end"><i class="bi bi-chevron-right"></i></div>
              </div>
              <a href="<?php echo e(route('medicines.show', $m)); ?>" class="stretched-link" aria-label="View <?php echo e($m->name); ?> details"></a>
            </div>
          </div>
        <?php endforeach; $__env->popLoop(); $loop = $__env->getLastLoop(); if ($__empty_1): ?>
          <div class="text-muted">No medicines match.</div>
        <?php endif; ?>
      </div>
      <div class="col-md-6">
        <h4>Offers</h4>
        <?php $__empty_1 = true; $__currentLoopData = $offers; $__env->addLoop($__currentLoopData); foreach($__currentLoopData as $o): $__env->incrementLoopIndices(); $loop = $__env->getLastLoop(); $__empty_1 = false; ?>
          <div class="card mb-2">
            <div class="card-body position-relative py-2">
              <div class="d-flex justify-content-between align-items-center">
                <div>
                  <strong><?php echo e($o->title); ?></strong>
                  <div class="small text-secondary"><?php echo e($o->pharmacy?->name); ?></div>
                </div>
                <div><i class="bi bi-chevron-right"></i></div>
              </div>
              <a href="<?php echo e(route('offers.show', $o)); ?>" class="stretched-link" aria-label="View <?php echo e($o->title); ?> details"></a>
            </div>
          </div>
        <?php endforeach; $__env->popLoop(); $loop = $__env->getLastLoop(); if ($__empty_1): ?>
          <div class="text-muted">No offers match.</div>
        <?php endif; ?>

        <h4 class="mt-4">Pharmacies</h4>
        <?php $__empty_1 = true; $__currentLoopData = $pharmacies; $__env->addLoop($__currentLoopData); foreach($__currentLoopData as $p): $__env->incrementLoopIndices(); $loop = $__env->getLastLoop(); $__empty_1 = false; ?>
          <div class="card mb-2 p-2 d-flex justify-content-between align-items-center">
            <div>
              <strong><?php echo e($p->name); ?></strong><div class="small text-secondary"><?php echo e(Str::limit($p->address,60)); ?></div>
            </div>
            <div>
              <form method="POST" action="<?php echo e(route('shop.request')); ?>">
                <?php echo csrf_field(); ?>
                <input type="hidden" name="type" value="pharmacy">
                <input type="hidden" name="id" value="<?php echo e($p->id); ?>">
                <button class="btn btn-sm btn-outline-secondary">Request</button>
              </form>
            </div>
          </div>
        <?php endforeach; $__env->popLoop(); $loop = $__env->getLastLoop(); if ($__empty_1): ?>
          <div class="text-muted">No pharmacies match.</div>
        <?php endif; ?>
      </div>
    </div>
  <?php endif; ?>
</div>
<?php $__env->stopSection(); ?>

<?php echo $__env->make('shop.layout', array_diff_key(get_defined_vars(), ['__data' => 1, '__path' => 1]))->render(); ?><?php /**PATH C:\Users\Lenovo\Desktop\Smart Pharmacy System\resources\views\shop\search.blade.php ENDPATH**/ ?>