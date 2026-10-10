<?php

namespace App\Domain;

use App\Models\JournalAction;
use Illuminate\Support\Str;

/**
 * Journal d'audit (spec §9 règle 14) : toute action importante laisse une trace
 * immuable avec acteur, appareil, motif, avant/après.
 */
final class AuditService
{
    public function journalise(
        string $entiteType,
        string $entiteId,
        string $action,
        ?array $avant = null,
        ?array $apres = null,
        ?string $motif = null,
        ?string $appareilId = null,
        ?string $acteurId = null,
    ): JournalAction {
        $ligne = JournalAction::create([
            'id' => (string) Str::uuid(),
            'entite_type' => $entiteType,
            'entite_id' => $entiteId,
            'action' => $action,
            'avant_json' => $avant,
            'apres_json' => $apres,
            'motif' => $motif,
            'appareil_id' => $appareilId,
            'acteur_id' => $acteurId,
            'date_action' => now(),
        ]);

        return $ligne;
    }

    public function historique(string $entiteType, string $entiteId, int $limite = 100): array
    {
        return JournalAction::query()
            ->where('entite_type', $entiteType)
            ->where('entite_id', $entiteId)
            ->orderBy('date_action')
            ->limit(min($limite, 500))
            ->get()
            ->map(fn (JournalAction $j) => [
                'id' => $j->id,
                'action' => $j->action,
                'motif' => $j->motif,
                'avant' => $j->avant_json,
                'apres' => $j->apres_json,
                'appareil_id' => $j->appareil_id,
                'date_action' => $j->date_action?->toIso8601String(),
            ])->all();
    }
}
