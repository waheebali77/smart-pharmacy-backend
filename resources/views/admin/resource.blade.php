@extends('admin.layouts.app')
@section('content')
@php use Illuminate\Support\Str; @endphp
@php use Illuminate\Support\Facades\Auth; @endphp
<div class="mb-4"><div class="eyebrow">{{ __('admin.management') }}</div><h1 class="page-title mb-1">{{ __($title) }}</h1><p class="text-secondary mb-0">{{ __($description) }}</p></div>
@if($section === 'settings')
<div class="card p-4"><form method="POST" action="{{ route('admin.settings.update') }}">@csrf @method('PUT')<div class="row g-3"><div class="col-md-4"><label class="form-label">Application name</label><input class="form-control" name="app_name" value="{{ old('app_name', $settings->app_name) }}" required></div><div class="col-md-4"><label class="form-label">Contact email</label><input class="form-control" type="email" name="contact_email" value="{{ old('contact_email', $settings->contact_email) }}"></div><div class="col-md-4"><label class="form-label">Contact phone</label><input class="form-control" name="contact_phone" value="{{ old('contact_phone', $settings->contact_phone) }}"></div><div class="col-12"><label class="form-label">Contact address</label><textarea class="form-control" name="contact_address" rows="2">{{ old('contact_address', $settings->contact_address) }}</textarea></div><div class="col-12"><label class="form-label">Privacy policy</label><textarea class="form-control" name="privacy_policy" rows="7">{{ old('privacy_policy', $settings->privacy_policy) }}</textarea></div><div class="col-12"><label class="form-label">Terms &amp; conditions</label><textarea class="form-control" name="terms_conditions" rows="7">{{ old('terms_conditions', $settings->terms_conditions) }}</textarea></div></div><button class="btn btn-primary mt-4"><i class="bi bi-check2 me-1"></i>Save application settings</button></form></div>
@elseif($section === 'pharmacies')
<div class="card p-4"><form class="row g-2 mb-3"><div class="col-md-4"><select class="form-select" name="status"><option value="">All statuses</option>@foreach(['pending','open','rejected','closed'] as $status)<option value="{{ $status }}" @selected(request('status') === $status)>{{ ucfirst($status) }}</option>@endforeach</select></div><div class="col-auto"><button class="btn btn-outline-secondary">Filter</button></div></form><div class="table-responsive"><table class="table"><thead><tr><th>Pharmacy</th><th>Owner</th><th>Contact</th><th>License</th><th>Status</th><th class="text-end">Actions</th></tr></thead><tbody>@forelse($items as $item)<tr><td><strong>{{ $item->name }}</strong><div class="small text-secondary">{{ Str::limit($item->address, 38) }}</div></td><td>{{ $item->user?->name }}<div class="small text-secondary">{{ $item->user?->email }}</div></td><td>{{ $item->phone ?: '—' }}</td><td>{{ $item->license_number ?: '—' }}</td><td><span class="badge badge-{{ $item->status }}">{{ ucfirst($item->status) }}</span></td><td class="text-end text-nowrap">@if($item->status === 'pending')<form class="d-inline" method="POST" action="{{ route('admin.pharmacies.approve',$item) }}">@csrf @method('PATCH')<button class="btn btn-sm btn-success" title="Approve"><i class="bi bi-check2"></i></button></form> <form class="d-inline" method="POST" action="{{ route('admin.pharmacies.request-info',$item) }}">@csrf @method('PATCH')<button class="btn btn-sm btn-outline-primary" title="Request additional information"><i class="bi bi-chat-square-text"></i></button></form> <form class="d-inline" method="POST" action="{{ route('admin.pharmacies.reject',$item) }}">@csrf @method('PATCH')<button class="btn btn-sm btn-outline-danger" title="Reject"><i class="bi bi-x-lg"></i></button></form>@else<span class="small text-secondary">Reviewed</span>@endif</td></tr>@empty<tr><td colspan="6" class="text-center text-secondary py-4">No pharmacies match this filter.</td></tr>@endforelse</tbody></table></div>{{ $items->withQueryString()->links() }}</div>
@elseif($section === 'users')
<div class="row g-4">
	<div class="col-xl-4">
		<div class="card p-4">
			<h2 class="h5">{{ isset($editUser) ? __('admin.edit_user') : __('admin.add_user') }}</h2>
			<form method="POST" action="{{ isset($editUser) ? route('admin.users.update', $editUser) : route('admin.users.store') }}">
				@csrf
				@if(isset($editUser)) @method('PATCH') @endif
				<input class="form-control mb-2" name="name" placeholder="{{ __('admin.full_name') }}" value="{{ old('name', $editUser->name ?? '') }}" required>
				<input class="form-control mb-2" type="email" name="email" placeholder="{{ __('admin.email') }}" value="{{ old('email', $editUser->email ?? '') }}" required>
				@if(!isset($editUser))
					<input class="form-control mb-2" type="password" name="password" placeholder="{{ __('admin.temporary_password') }}" required>
				@else
					<input class="form-control mb-2" type="password" name="password" placeholder="{{ __('admin.new_password') }}">
				@endif
				<select class="form-select mb-3" name="role">
					<option value="admin" @selected(old('role', $editUser->role ?? '')==='admin')>{{ __('admin.administrator') }}</option>
					<option value="manager" @selected(old('role', $editUser->role ?? '')==='manager')>{{ __('admin.manager') }}</option>
				</select>
				<button class="btn btn-primary w-100">{{ isset($editUser) ? __('admin.save_changes') : __('admin.create_user') }}</button>
				@if(isset($editUser))<a href="{{ route('admin.users') }}" class="btn btn-link mt-2">{{ __('admin.cancel') }}</a>@endif
			</form>
		</div>
	</div>
	<div class="col-xl-8">
		<div class="card p-4 mb-3">
			<form class="row g-2" method="GET" action="{{ route('admin.users') }}">
				<div class="col">
					<input class="form-control" name="q" placeholder="{{ __('admin.search_name_email') }}" value="{{ $search ?? '' }}">
				</div>
				<div class="col-auto"><button class="btn btn-outline-secondary">{{ __('admin.search') }}</button></div>
			</form>
		</div>
		<div class="card p-4">
			<div class="table-responsive">
				<table class="table">
					<thead><tr><th>{{ __('admin.name') }}</th><th>{{ __('admin.email') }}</th><th>{{ __('admin.role') }}</th><th>{{ __('admin.joined') }}</th><th></th></tr></thead>
					<tbody>
						@foreach($items as $item)
							<tr>
								<td class="fw-semibold">{{ $item->name }}</td>
								<td>{{ $item->email }}</td>
								<td><span class="badge bg-light text-dark">{{ str_replace('_',' ',ucfirst($item->role)) }}</span></td>
								<td>{{ $item->created_at->format('d M Y') }}</td>
								<td class="text-end">
									@if(!$item->is(Auth::user()))
										<a href="{{ route('admin.users.edit', $item) }}" class="btn btn-sm btn-outline-primary me-2"><i class="bi bi-pencil"></i></a>
										<form class="d-inline" method="POST" action="{{ route('admin.users.destroy',$item) }}">
											@csrf @method('DELETE')
											<button class="btn btn-sm btn-outline-danger"><i class="bi bi-trash"></i></button>
										</form>
									@endif
								</td>
							</tr>
						@endforeach
					</tbody>
				</table>
			</div>
			{{ $items->links() }}
		</div>
	</div>
</div>
@elseif($section === 'app-users')
<div class="row g-4">
	<div class="col-xl-4"><div class="card p-4"><h2 class="h5">{{ __('admin.add_app_user') }}</h2><form method="POST" action="{{ route('admin.app-users.store') }}">@csrf<input class="form-control mb-2" name="name" placeholder="{{ __('admin.full_name') }}" required><input class="form-control mb-2" type="email" name="email" placeholder="{{ __('admin.email') }}" required><input class="form-control mb-2" name="phone" placeholder="{{ __('admin.phone') }}"><input class="form-control mb-2" type="password" name="password" placeholder="{{ __('admin.temporary_password') }}" required><select class="form-select mb-3" name="role"><option value="customer">{{ __('admin.customer') }}</option><option value="pharmacy_owner">{{ __('admin.pharmacy_owner') }}</option></select><button class="btn btn-primary w-100">{{ __('admin.create_user') }}</button></form></div></div>
	<div class="col-xl-8"><div class="card p-4 mb-3"><form class="row g-2" method="GET" action="{{ route('admin.app-users') }}"><div class="col"><input class="form-control" name="q" placeholder="{{ __('admin.search_name_email') }}" value="{{ $search ?? '' }}"></div><div class="col-auto"><button class="btn btn-outline-secondary">{{ __('admin.search') }}</button></div></form></div><div class="card p-4"><div class="table-responsive"><table class="table"><thead><tr><th>{{ __('admin.name') }}</th><th>{{ __('admin.email') }}</th><th>{{ __('admin.role') }}</th><th>{{ __('admin.status') }}</th><th>{{ __('admin.actions') }}</th></tr></thead><tbody>@foreach($items as $item)<tr><td class="fw-semibold">{{ $item->name }}<div class="small text-secondary">{{ $item->phone ?: '—' }}</div></td><td>{{ $item->email }}</td><td>{{ $item->role === 'pharmacy_owner' ? __('admin.pharmacy_owner') : __('admin.customer') }}</td><td><span class="badge {{ $item->is_active ? 'badge-open' : 'badge-closed' }}">{{ $item->is_active ? __('admin.active') : __('admin.inactive') }}</span></td><td class="text-nowrap"><form class="d-inline" method="POST" action="{{ route('admin.app-users.status', $item) }}">@csrf @method('PATCH')<button class="btn btn-sm btn-outline-warning">{{ $item->is_active ? __('admin.deactivate') : __('admin.activate') }}</button></form> <form class="d-inline" method="POST" action="{{ route('admin.app-users.destroy', $item) }}" onsubmit="return confirm('{{ __('admin.delete_app_user_confirm') }}')">@csrf @method('DELETE')<button class="btn btn-sm btn-outline-danger"><i class="bi bi-trash"></i></button></form></td></tr>@endforeach</tbody></table></div>{{ $items->links() }}</div></div>
</div>
@elseif($section === 'categories')
<div class="row g-4"><div class="col-lg-4"><div class="card p-4"><h2 class="h5">New category</h2><form method="POST" action="{{ route('admin.categories.store') }}">@csrf<input class="form-control mb-2" name="name" placeholder="Category name" required><textarea class="form-control mb-3" name="description" rows="3" placeholder="Description"></textarea><button class="btn btn-primary">Add category</button></form></div></div><div class="col-lg-8"><div class="card p-4"><table class="table"><thead><tr><th>Name</th><th>Description</th><th>Medicines</th><th></th></tr></thead><tbody>@foreach($items as $item)<tr><td class="fw-semibold">{{ $item->name }}</td><td>{{ Str::limit($item->description,55) }}</td><td>{{ $item->medicines_count }}</td><td class="text-end"><form method="POST" action="{{ route('admin.categories.destroy',$item) }}">@csrf @method('DELETE')<button class="btn btn-sm btn-outline-danger"><i class="bi bi-trash"></i></button></form></td></tr>@endforeach</tbody></table>{{ $items->links() }}</div></div></div>
@elseif($section === 'medicines')
<div class="card p-4 mb-4"><h2 class="h5">Add medicine</h2><form method="POST" action="{{ route('admin.medicines.store') }}">@csrf<div class="row g-2"><div class="col-md-3"><input class="form-control" name="name" placeholder="Medicine name" required></div><div class="col-md-2"><select class="form-select" name="category_id" required><option value="">Category</option>@foreach($categories as $category)<option value="{{ $category->id }}">{{ $category->name }}</option>@endforeach</select></div><div class="col-md-2"><input class="form-control" name="price" type="number" step=".01" placeholder="Price" required></div><div class="col-md-2"><input class="form-control" name="quantity" type="number" placeholder="Quantity" required></div><div class="col-md-2"><input class="form-control" name="discount_percentage" type="number" placeholder="Discount %" required></div><div class="col-md-1"><button class="btn btn-primary w-100" title="Add medicine"><i class="bi bi-plus-lg"></i></button></div></div></form></div><div class="card p-4"><div class="table-responsive"><table class="table"><thead><tr><th>Medicine</th><th>Category</th><th>Price</th><th>Stock</th><th>Available</th><th></th></tr></thead><tbody>@foreach($items as $item)<tr><td class="fw-semibold">{{ $item->name }}</td><td>{{ $item->category?->name }}</td><td>${{ number_format($item->price,2) }}</td><td>{{ $item->quantity }}</td><td><span class="badge {{ $item->is_available ? 'badge-open' : 'badge-closed' }}">{{ $item->is_available ? 'Yes' : 'No' }}</span></td><td class="text-end"><form method="POST" action="{{ route('admin.medicines.destroy',$item) }}">@csrf @method('DELETE')<button class="btn btn-sm btn-outline-danger"><i class="bi bi-trash"></i></button></form></td></tr>@endforeach</tbody></table></div>{{ $items->links() }}</div>
@elseif($section === 'offers')
<div class="card p-4 mb-4"><h2 class="h5">Publish offer</h2><form method="POST" action="{{ route('admin.offers.store') }}">@csrf<div class="row g-2"><div class="col-md-3"><input class="form-control" name="title" placeholder="Offer title" required></div><div class="col-md-3"><select class="form-select" name="pharmacy_id" required><option value="">Pharmacy</option>@foreach($pharmacies as $pharmacy)<option value="{{ $pharmacy->id }}">{{ $pharmacy->name }}</option>@endforeach</select></div><div class="col-md-2"><input class="form-control" name="discount_percentage" type="number" placeholder="Discount %" required></div><div class="col-md-2"><input class="form-control" name="start_date" type="date" required></div><div class="col-md-2"><input class="form-control" name="end_date" type="date" required></div></div><button class="btn btn-primary mt-3">Publish offer</button></form></div><div class="card p-4"><table class="table"><thead><tr><th>Offer</th><th>Pharmacy</th><th>Discount</th><th>Dates</th><th></th></tr></thead><tbody>@foreach($items as $item)<tr><td class="fw-semibold">{{ $item->title }}</td><td>{{ $item->pharmacy?->name }}</td><td>{{ $item->discount_percentage }}%</td><td>{{ $item->start_date }} to {{ $item->end_date }}</td><td class="text-end"><form method="POST" action="{{ route('admin.offers.destroy',$item) }}">@csrf @method('DELETE')<button class="btn btn-sm btn-outline-danger"><i class="bi bi-trash"></i></button></form></td></tr>@endforeach</tbody></table>{{ $items->links() }}</div>
@elseif($section === 'orders')
<div class="card p-4"><div class="table-responsive"><table class="table"><thead><tr><th>Order</th><th>Customer</th><th>Pharmacy</th><th>Total</th><th>Status</th><th>Update</th></tr></thead><tbody>@foreach($items as $item)<tr><td class="fw-semibold">#{{ $item->id }}</td><td>{{ $item->user?->name }}</td><td>{{ $item->pharmacy?->name }}</td><td>${{ number_format($item->total_price,2) }}</td><td><span class="badge bg-light text-dark">{{ ucfirst($item->status) }}</span></td><td><form class="d-flex gap-2" method="POST" action="{{ route('admin.orders.status',$item) }}">@csrf @method('PATCH')<select class="form-select form-select-sm" name="status">@foreach(['pending','accepted','rejected','preparing','ready','delivered','cancelled'] as $status)<option @selected($item->status === $status)>{{ $status }}</option>@endforeach</select><button class="btn btn-sm btn-primary"><i class="bi bi-check2"></i></button></form></td></tr>@endforeach</tbody></table></div>{{ $items->links() }}</div>
@elseif(in_array($section, ['notifications','activity-logs']))
<div class="card p-4"><div class="table-responsive"><table class="table"><thead><tr><th>Type</th><th>User</th><th>Pharmacy</th><th>Details</th><th>Created</th></tr></thead><tbody>@foreach($items as $item)<tr><td class="fw-semibold">{{ str_replace('.', ' / ', ucfirst($item->type)) }}</td><td>{{ $item->user?->name ?: $item->dashboardUser?->name ?: 'System' }}</td><td>{{ $item->pharmacy?->name ?: '—' }}</td><td>{{ data_get(json_decode($item->data, true), 'message', Str::limit($item->data, 70)) }}</td><td>{{ $item->created_at->format('d M Y, H:i') }}</td></tr>@endforeach</tbody></table></div>{{ $items->links() }}</div>
@endif
@endsection