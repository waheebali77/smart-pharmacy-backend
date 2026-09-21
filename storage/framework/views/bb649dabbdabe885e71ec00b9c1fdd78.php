
<?php $__env->startSection('content'); ?>
<div class="py-4">
  <a href="<?php echo e(url()->previous()); ?>" class="btn btn-link mb-3">&larr; Back</a>
  <div class="card p-4">
    <h2><?php echo e($medicine->name); ?></h2>
    <p class="text-secondary"><?php echo e($medicine->category?->name); ?></p>
    <p><?php echo e($medicine->description); ?></p>
    <p><strong>Price:</strong> $<?php echo e(number_format($medicine->price,2)); ?></p>
    <p><strong>Available:</strong> <?php echo e($available ? 'Yes' : 'No'); ?></p>

    <div class="d-flex gap-2 mt-3">
      <a href="<?php echo e(route('shop.search', ['q' => request('q')])); ?>" class="btn btn-outline-secondary">Cancel</a>
      <?php if($available): ?>
        <form method="POST" action="<?php echo e(route('cart.add')); ?>">
          <?php echo csrf_field(); ?>
          <input type="hidden" name="medicine_id" value="<?php echo e($medicine->id); ?>">
          <input type="number" name="quantity" value="1" min="1" class="form-control d-inline-block" style="width:100px">
          <button class="btn btn-primary">Add</button>
        </form>
      <?php else: ?>
        <form method="POST" action="<?php echo e(route('shop.request')); ?>">
          <?php echo csrf_field(); ?>
          <input type="hidden" name="type" value="medicine">
          <input type="hidden" name="id" value="<?php echo e($medicine->id); ?>">
          <button class="btn btn-primary">Request</button>
        </form>
      <?php endif; ?>
    </div>
  </div>
</div>
<?php $__env->stopSection(); ?>

<?php echo $__env->make('shop.layout', array_diff_key(get_defined_vars(), ['__data' => 1, '__path' => 1]))->render(); ?><?php /**PATH C:\Users\Lenovo\Desktop\Smart Pharmacy System\resources\views\shop\medicine.blade.php ENDPATH**/ ?>