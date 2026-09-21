
<?php $__env->startSection('content'); ?>
<div class="py-4">
  <a href="<?php echo e(url()->previous()); ?>" class="btn btn-link mb-3">&larr; Back</a>
  <div class="card p-4">
    <h2><?php echo e($offer->title); ?></h2>
    <p class="text-secondary"><?php echo e($pharmacy?->name); ?></p>
    <p><?php echo e($offer->description); ?></p>
    <p><strong>Discount:</strong> <?php echo e($offer->discount_percentage); ?>%</p>
    <div class="d-flex gap-2 mt-3">
      <a href="<?php echo e(route('shop.search', ['q' => request('q')])); ?>" class="btn btn-outline-secondary">Cancel</a>
      <form method="POST" action="<?php echo e(route('shop.request')); ?>">
        <?php echo csrf_field(); ?>
        <input type="hidden" name="type" value="offer">
        <input type="hidden" name="id" value="<?php echo e($offer->id); ?>">
        <button class="btn btn-primary">Request</button>
      </form>
    </div>
  </div>
</div>
<?php $__env->stopSection(); ?>

<?php echo $__env->make('shop.layout', array_diff_key(get_defined_vars(), ['__data' => 1, '__path' => 1]))->render(); ?><?php /**PATH C:\Users\Lenovo\Desktop\Smart Pharmacy System\resources\views\shop\offer.blade.php ENDPATH**/ ?>