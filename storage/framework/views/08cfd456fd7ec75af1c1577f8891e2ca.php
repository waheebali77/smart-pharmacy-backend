
<?php $__env->startSection('content'); ?>
<div class="py-4">
  <h1>Your cart</h1>
  <?php $items = $cart['items'] ?? []; ?>
  <?php if(empty($items)): ?>
    <div class="alert alert-info">Your cart is empty. Browse <a href="<?php echo e(route('medicines.index')); ?>">medicines</a>.</div>
  <?php else: ?>
    <div class="card p-3 mb-3">
      <table class="table mb-0">
        <thead><tr><th>Item</th><th>Price</th><th>Qty</th><th>Subtotal</th></tr></thead>
        <tbody>
        <?php $total = 0; ?>
        <?php $__currentLoopData = $items; $__env->addLoop($__currentLoopData); foreach($__currentLoopData as $it): $__env->incrementLoopIndices(); $loop = $__env->getLastLoop(); ?>
          <?php $subtotal = $it['price'] * $it['quantity']; $total += $subtotal; ?>
          <tr><td><?php echo e($it['name']); ?></td><td>$<?php echo e(number_format($it['price'],2)); ?></td><td><?php echo e($it['quantity']); ?></td><td>$<?php echo e(number_format($subtotal,2)); ?></td></tr>
        <?php endforeach; $__env->popLoop(); $loop = $__env->getLastLoop(); ?>
        </tbody>
      </table>
    </div>
    <div class="d-flex justify-content-between align-items-center">
      <div><a href="<?php echo e(route('medicines.index')); ?>" class="btn btn-outline-secondary">Continue shopping</a></div>
      <div>
        <strong class="me-3">Total: $<?php echo e(number_format($total,2)); ?></strong>
        <a href="<?php echo e(route('checkout.index')); ?>" class="btn btn-primary">Checkout</a>
      </div>
    </div>
  <?php endif; ?>
</div>
<?php $__env->stopSection(); ?>

<?php echo $__env->make('shop.layout', array_diff_key(get_defined_vars(), ['__data' => 1, '__path' => 1]))->render(); ?><?php /**PATH C:\Users\Lenovo\Desktop\Smart Pharmacy System\resources\views\shop\cart.blade.php ENDPATH**/ ?>