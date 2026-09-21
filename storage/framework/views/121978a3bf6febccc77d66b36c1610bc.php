
<?php $__env->startSection('content'); ?>
<div class="py-4">
  <h1>Your orders</h1>
  <?php $__empty_1 = true; $__currentLoopData = $items; $__env->addLoop($__currentLoopData); foreach($__currentLoopData as $order): $__env->incrementLoopIndices(); $loop = $__env->getLastLoop(); $__empty_1 = false; ?>
    <div class="card mb-3 p-3">
      <div class="d-flex justify-content-between">
        <div>
          <strong>Order #<?php echo e($order->id); ?></strong>
          <div class="small text-secondary">Status: <?php echo e(ucfirst($order->status)); ?></div>
        </div>
        <div>
          <div class="small text-secondary">Total: $<?php echo e(number_format($order->total_price,2)); ?></div>
          <div class="small text-secondary">Placed: <?php echo e($order->created_at->format('d M Y, H:i')); ?></div>
        </div>
      </div>
      <?php if($order->items->isNotEmpty()): ?>
        <hr>
        <ul class="mb-0">
          <?php $__currentLoopData = $order->items; $__env->addLoop($__currentLoopData); foreach($__currentLoopData as $it): $__env->incrementLoopIndices(); $loop = $__env->getLastLoop(); ?>
            <li><?php echo e($it->medicine?->name); ?> — <?php echo e($it->quantity); ?> x $<?php echo e(number_format($it->price,2)); ?></li>
          <?php endforeach; $__env->popLoop(); $loop = $__env->getLastLoop(); ?>
        </ul>
      <?php endif; ?>
    </div>
  <?php endforeach; $__env->popLoop(); $loop = $__env->getLastLoop(); if ($__empty_1): ?>
    <div class="alert alert-info">You have not placed any orders yet.</div>
  <?php endif; ?>

  <?php echo e($items->links()); ?>

</div>
<?php $__env->stopSection(); ?>

<?php echo $__env->make('shop.layout', array_diff_key(get_defined_vars(), ['__data' => 1, '__path' => 1]))->render(); ?><?php /**PATH C:\Users\Lenovo\Desktop\Smart Pharmacy System\resources\views\shop\orders.blade.php ENDPATH**/ ?>