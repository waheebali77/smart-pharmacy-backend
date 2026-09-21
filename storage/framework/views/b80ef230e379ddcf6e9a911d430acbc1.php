<div class="modal fade" id="countryModal" tabindex="-1"><div class="modal-dialog"><form class="modal-content" method="POST" action="<?php echo e(route('admin.locations.countries.store')); ?>">
    <?php echo csrf_field(); ?> <div class="modal-header"><h5 class="modal-title">Add country</h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
    <div class="modal-body"><?php echo $__env->make('admin.locations-form', ['country' => null], array_diff_key(get_defined_vars(), ['__data' => 1, '__path' => 1]))->render(); ?></div>
    <div class="modal-footer"><button type="button" class="btn btn-light" data-bs-dismiss="modal">Cancel</button><button class="btn btn-primary">Save country</button></div>
</form></div></div>
<?php $__currentLoopData = $countries; $__env->addLoop($__currentLoopData); foreach($__currentLoopData as $country): $__env->incrementLoopIndices(); $loop = $__env->getLastLoop(); ?>
<div class="modal fade" id="editCountry-<?php echo e($country->id); ?>" tabindex="-1"><div class="modal-dialog"><form class="modal-content" method="POST" action="<?php echo e(route('admin.locations.countries.update', $country)); ?>">
    <?php echo csrf_field(); ?> <?php echo method_field('PUT'); ?> <div class="modal-header"><h5 class="modal-title">Edit country</h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
    <div class="modal-body"><?php echo $__env->make('admin.locations-form', ['country' => $country], array_diff_key(get_defined_vars(), ['__data' => 1, '__path' => 1]))->render(); ?></div>
    <div class="modal-footer"><button type="button" class="btn btn-light" data-bs-dismiss="modal">Cancel</button><button class="btn btn-primary">Save changes</button></div>
</form></div></div>
<div class="modal fade" id="governorate-<?php echo e($country->id); ?>" tabindex="-1"><div class="modal-dialog"><form class="modal-content" method="POST" action="<?php echo e(route('admin.locations.governorates.store', $country)); ?>">
    <?php echo csrf_field(); ?> <div class="modal-header"><h5 class="modal-title">Add governorate to <?php echo e($country->name_en); ?></h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
    <div class="modal-body"><?php echo $__env->make('admin.governorate-form', ['governorate' => null], array_diff_key(get_defined_vars(), ['__data' => 1, '__path' => 1]))->render(); ?></div>
    <div class="modal-footer"><button type="button" class="btn btn-light" data-bs-dismiss="modal">Cancel</button><button class="btn btn-primary">Add governorate</button></div>
</form></div></div>
<?php $__currentLoopData = $country->governorates; $__env->addLoop($__currentLoopData); foreach($__currentLoopData as $governorate): $__env->incrementLoopIndices(); $loop = $__env->getLastLoop(); ?>
<div class="modal fade" id="editGovernorate-<?php echo e($governorate->id); ?>" tabindex="-1"><div class="modal-dialog"><form class="modal-content" method="POST" action="<?php echo e(route('admin.locations.governorates.update', $governorate)); ?>">
    <?php echo csrf_field(); ?> <?php echo method_field('PUT'); ?> <div class="modal-header"><h5 class="modal-title">Edit governorate</h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
    <div class="modal-body"><?php echo $__env->make('admin.governorate-form', ['governorate' => $governorate], array_diff_key(get_defined_vars(), ['__data' => 1, '__path' => 1]))->render(); ?></div>
    <div class="modal-footer"><button type="button" class="btn btn-light" data-bs-dismiss="modal">Cancel</button><button class="btn btn-primary">Save changes</button></div>
</form></div></div>
<?php endforeach; $__env->popLoop(); $loop = $__env->getLastLoop(); ?>
<?php endforeach; $__env->popLoop(); $loop = $__env->getLastLoop(); ?>
<?php /**PATH C:\Users\Lenovo\Desktop\Smart Pharmacy System\resources\views/admin/locations-modals.blade.php ENDPATH**/ ?>