

<?php $__env->startSection('content'); ?>
<div class="d-flex flex-wrap justify-content-between align-items-end gap-3 mb-4">
    <div>
        <div class="eyebrow">Location management</div>
        <h1 class="page-title mb-1">Countries & governorates</h1>
        <p class="text-secondary mb-0">Manage the locations shown during mobile app onboarding.</p>
    </div>
    <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#countryModal">
        <i class="bi bi-plus-lg me-1"></i>Add country
    </button>
</div>

<div class="row g-4">
    <div class="col-lg-5">
        <div class="card h-100">
            <div class="card-body p-0">
                <div class="p-4 border-bottom">
                    <h5 class="mb-1">Countries</h5>
                    <div class="small text-secondary"><?php echo e($countries->count()); ?> countries configured</div>
                </div>
                <div class="list-group list-group-flush">
                    <?php $__empty_1 = true; $__currentLoopData = $countries; $__env->addLoop($__currentLoopData); foreach($__currentLoopData as $country): $__env->incrementLoopIndices(); $loop = $__env->getLastLoop(); $__empty_1 = false; ?>
                        <button class="list-group-item list-group-item-action country-row d-flex align-items-center justify-content-between p-3"
                                data-country="<?php echo e($country->id); ?>">
                            <span>
                                <strong><?php echo e($country->name_en); ?></strong>
                                <span class="text-secondary small d-block"><?php echo e($country->name_ar); ?> · <?php echo e($country->code); ?></span>
                            </span>
                            <span class="badge rounded-pill text-bg-light"><?php echo e($country->governorates->count()); ?></span>
                        </button>
                    <?php endforeach; $__env->popLoop(); $loop = $__env->getLastLoop(); if ($__empty_1): ?>
                        <div class="p-4 text-secondary">No countries yet. Add the first country to get started.</div>
                    <?php endif; ?>
                </div>
            </div>
        </div>
    </div>

    <div class="col-lg-7">
        <?php $__currentLoopData = $countries; $__env->addLoop($__currentLoopData); foreach($__currentLoopData as $country): $__env->incrementLoopIndices(); $loop = $__env->getLastLoop(); ?>
            <section class="card country-panel" id="country-panel-<?php echo e($country->id); ?>" hidden>
                <div class="card-body">
                    <div class="d-flex justify-content-between align-items-start gap-3 mb-4">
                        <div>
                            <div class="eyebrow"><?php echo e($country->code); ?></div>
                            <h4 class="mb-1"><?php echo e($country->name_en); ?></h4>
                            <div class="text-secondary"><?php echo e($country->name_ar); ?></div>
                        </div>
                        <div class="d-flex gap-2">
                            <button class="btn btn-sm btn-outline-secondary" data-bs-toggle="modal" data-bs-target="#editCountry-<?php echo e($country->id); ?>"><i class="bi bi-pencil"></i></button>
                            <form method="POST" action="<?php echo e(route('admin.locations.countries.destroy', $country)); ?>" onsubmit="return confirm('Delete this country and all its governorates?')">
                                <?php echo csrf_field(); ?> <?php echo method_field('DELETE'); ?>
                                <button class="btn btn-sm btn-outline-danger"><i class="bi bi-trash"></i></button>
                            </form>
                        </div>
                    </div>
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h6 class="mb-0">Governorates</h6>
                        <button class="btn btn-sm btn-primary" data-bs-toggle="modal" data-bs-target="#governorate-<?php echo e($country->id); ?>"><i class="bi bi-plus-lg me-1"></i>Add</button>
                    </div>
                    <div class="table-responsive">
                        <table class="table align-middle mb-0">
                            <thead><tr><th>Arabic name</th><th>English name</th><th class="text-end">Actions</th></tr></thead>
                            <tbody>
                            <?php $__empty_1 = true; $__currentLoopData = $country->governorates; $__env->addLoop($__currentLoopData); foreach($__currentLoopData as $governorate): $__env->incrementLoopIndices(); $loop = $__env->getLastLoop(); $__empty_1 = false; ?>
                                <tr>
                                    <td><?php echo e($governorate->name_ar); ?></td><td><?php echo e($governorate->name_en); ?></td>
                                    <td class="text-end text-nowrap">
                                        <button class="btn btn-sm btn-link text-secondary" data-bs-toggle="modal" data-bs-target="#editGovernorate-<?php echo e($governorate->id); ?>"><i class="bi bi-pencil"></i></button>
                                        <form class="d-inline" method="POST" action="<?php echo e(route('admin.locations.governorates.destroy', $governorate)); ?>" onsubmit="return confirm('Delete this governorate?')">
                                            <?php echo csrf_field(); ?> <?php echo method_field('DELETE'); ?><button class="btn btn-sm btn-link text-danger"><i class="bi bi-trash"></i></button>
                                        </form>
                                    </td>
                                </tr>
                            <?php endforeach; $__env->popLoop(); $loop = $__env->getLastLoop(); if ($__empty_1): ?>
                                <tr><td colspan="3" class="text-secondary py-4">No governorates configured.</td></tr>
                            <?php endif; ?>
                            </tbody>
                        </table>
                    </div>
                </div>
            </section>
        <?php endforeach; $__env->popLoop(); $loop = $__env->getLastLoop(); ?>
        <div id="empty-location-state" class="card"><div class="card-body text-center text-secondary py-5"><i class="bi bi-globe2 fs-1 d-block mb-3"></i>Select a country to manage its governorates.</div></div>
    </div>
</div>

<?php echo $__env->make('admin.locations-modals', array_diff_key(get_defined_vars(), ['__data' => 1, '__path' => 1]))->render(); ?>
<?php $__env->stopSection(); ?>

<?php $__env->startPush('scripts'); ?>
<script>
document.addEventListener('DOMContentLoaded', function () {
    const rows = document.querySelectorAll('.country-row');
    const panels = document.querySelectorAll('.country-panel');
    const empty = document.getElementById('empty-location-state');
    function show(id) {
        panels.forEach(panel => panel.hidden = panel.id !== `country-panel-${id}`);
        empty.hidden = Boolean(id);
        rows.forEach(row => row.classList.toggle('active', row.dataset.country === String(id)));
    }
    rows.forEach(row => row.addEventListener('click', () => show(row.dataset.country)));
    if (rows.length) show(rows[0].dataset.country);
});
</script>
<?php $__env->stopPush(); ?>

<?php echo $__env->make('admin.layouts.app', array_diff_key(get_defined_vars(), ['__data' => 1, '__path' => 1]))->render(); ?><?php /**PATH C:\Users\Lenovo\Desktop\Smart Pharmacy System\resources\views\admin\locations.blade.php ENDPATH**/ ?>