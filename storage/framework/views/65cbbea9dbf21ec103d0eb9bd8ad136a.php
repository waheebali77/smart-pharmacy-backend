
<?php $__env->startSection('content'); ?>
<div class="py-4">
  <h1>Checkout</h1>
  <form method="POST" action="<?php echo e(route('checkout.place')); ?>">
    <?php echo csrf_field(); ?>
    <div class="mb-3">
      <label class="form-label">Delivery address</label>
      <textarea name="address" class="form-control" rows="3" required></textarea>
    </div>
    <div class="mb-3">
      <p class="text-muted">Payment is mocked for this demo — orders will be created as pending.</p>
    </div>
    <button class="btn btn-primary">Place order</button>
  </form>
</div>
<?php $__env->stopSection(); ?>

<?php echo $__env->make('shop.layout', array_diff_key(get_defined_vars(), ['__data' => 1, '__path' => 1]))->render(); ?><?php /**PATH C:\Users\Lenovo\Desktop\Smart Pharmacy System\resources\views\shop\checkout.blade.php ENDPATH**/ ?>