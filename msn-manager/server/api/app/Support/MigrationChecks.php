<?php

namespace App\Support;

use Illuminate\Support\Facades\DB;

/**
 * Applique les contraintes CHECK au moteur qui les supporte en ALTER TABLE.
 * - PostgreSQL (serveur autoritaire) : ALTER TABLE ... ADD CONSTRAINT.
 * - SQLite (tests rapides Laravel) : les CHECK équivalents sont déclarés
 *   inline à la création des tables dans le schéma Drift côté client
 *   (packages/core), conformément à la spec §5.1 : « les CHECK SQL ne
 *   remplacent pas les validations Laravel ».
 */
final class MigrationChecks
{
    /** @param array<int, string> $statements */
    public static function applique(array $statements): void
    {
        if (DB::getDriverName() === 'pgsql') {
            foreach ($statements as $sql) {
                DB::statement($sql);
            }
        }
    }
}
