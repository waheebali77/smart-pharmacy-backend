<div class="mb-3"><label class="form-label">Arabic name</label><input class="form-control" name="name_ar" value="{{ old('name_ar', $country?->name_ar) }}" required></div>
<div class="mb-3"><label class="form-label">English name</label><input class="form-control" name="name_en" value="{{ old('name_en', $country?->name_en) }}" required></div>
<div>
    <label class="form-label">Code</label>
    <input class="form-control text-uppercase" name="code" maxlength="2" pattern="[A-Za-z]{2}" value="{{ old('code', $country?->code) }}" required>
    <div class="form-text">Use two English letters, for example YE or SA.</div>
</div>
