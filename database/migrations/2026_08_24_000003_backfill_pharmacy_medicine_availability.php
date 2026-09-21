<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration {
    public function up(): void
    {
        DB::statement(<<<'SQL'
            UPDATE pharmacy_medicines pm
            INNER JOIN medicines m ON m.id = pm.medicine_id
            SET pm.is_available = (m.is_available = 1 AND pm.quantity > 0)
            WHERE pm.is_available = 0
        SQL);
    }

    public function down(): void
    {
        // Availability is pharmacy-owned state and cannot be reconstructed safely.
    }
};
