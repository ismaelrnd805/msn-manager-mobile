<?php

namespace App\Domain;

use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

/**
 * Numérotation atomique DEV-AAAA-NNNN (devis), CMD-..., FAC-...
 * Table `sequences` incrémentée dans la transaction courante → aucune collision (spec §12).
 */
final class NumeroService
{
    public function suivant(string $code): string
    {
        $annee = (int) now()->format('Y');

        return DB::transaction(function () use ($code, $annee) {
            $updated = DB::table('sequences')
                ->where('code', $code)
                ->where('annee', $annee)
                ->update(['dernier_numero' => DB::raw('dernier_numero + 1')]);

            if ($updated === 0) {
                try {
                    DB::table('sequences')->insert([
                        'code' => $code,
                        'annee' => $annee,
                        'dernier_numero' => 1,
                        'created_at' => now(),
                        'updated_at' => now(),
                    ]);
                    $numero = 1;
                } catch (\Throwable) {
                    // Course d'insertion : relecture verrouillée
                    $row = DB::table('sequences')
                        ->where('code', $code)->where('annee', $annee)
                        ->lockForUpdate()->first();
                    DB::table('sequences')
                        ->where('code', $code)->where('annee', $annee)
                        ->update(['dernier_numero' => DB::raw('dernier_numero + 1')]);
                    $numero = $row->dernier_numero + 1;
                }
            } else {
                $row = DB::table('sequences')
                    ->where('code', $code)->where('annee', $annee)->first();
                $numero = $row->dernier_numero;
            }

            $prefixe = match ($code) {
                'DEVIS' => 'DEV',
                'CMD' => 'CMD',
                'FAC' => 'FAC',
                default => strtoupper($code),
            };

            return sprintf('%s-%d-%04d', $prefixe, $annee, $numero);
        });
    }
}
