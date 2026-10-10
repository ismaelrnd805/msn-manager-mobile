<?php

namespace App\Http\Controllers\Api\V1;

use Illuminate\Support\Str;
use App\Http\Controllers\Api\V1\ApiController;
use App\Domain\AuditService;
use App\Domain\SyncService;
use App\Models\Appareil;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;

/** Synchronisation (spec §8) : push, pull, statut + pièces jointes séparées. */
final class AttachmentsController extends ApiController
{
    /** POST /attachments : déclare une pièce jointe (métadonnées). */
    public function declare(Request $request): JsonResponse
    {
        $d = $request->validate([
            'id' => ['nullable', 'uuid'],
            'client_id' => ['nullable', 'uuid'],
            'demande_id' => ['nullable', 'uuid'],
            'commande_id' => ['nullable', 'uuid'],
            'projet_id' => ['nullable', 'uuid'],
            'nom_fichier' => ['required', 'string', 'max:190'],
            'mime_type' => ['required', 'string', 'max:120'],
            'taille_octets' => ['required', 'integer', 'min:0', 'max:26214400'], // 25 Mo (spec §8.6)
            'sha256' => ['required', 'string', 'size:64', 'regex:/^[0-9a-f]{64}$/i'],
        ]);
        if (empty(array_intersect_key($d, array_flip(['client_id', 'demande_id', 'commande_id', 'projet_id'])))) {
            return $this->erreur('VALIDATION_ERROR', 'La pièce jointe doit être rattachée à au moins une entité.', 422);
        }

        return DB::transaction(function () use ($d, $request) {
            $pj = \App\Models\PieceJointe::create($d + [
                'id' => $d['id'] ?? \Illuminate\Support\Str::uuid(),
                'statut_transfert' => 'a_transferer',
                'version' => 1,
            ]);
            app(AuditService::class)->journalise('pieces_jointes', $pj->id, 'declaration', null, $pj->toArray(), null, $request->header('X-Device-Id'), optional($request->user())->id);

            return $this->ok($pj, 201);
        });
    }

    /** PUT /attachments/{id}/content : envoie le contenu (vérification taille + SHA-256 à la complétion). */
    public function contenu(Request $request, string $id): JsonResponse
    {
        $pj = \App\Models\PieceJointe::query()->findOrFail($id);
        if ($pj->statut_transfert === 'synchronise') {
            return $this->erreur('DEJA_TRANSFERE', 'Le contenu a déjà été transféré et vérifié.', 409);
        }
        $contenu = $request->getContent();
        if ((int) $request->header('Content-Length', 0) !== (int) $pj->taille_octets) {
            return $this->erreur('TAILLE_INVALIDE', 'Taille reçue différente de la taille déclarée.', 409);
        }
        $cle = 'attachments/'.$pj->id;
        Storage::disk('local')->put($cle, $contenu);

        return $this->ok(['cle' => $cle, 'recu_octets' => strlen($contenu)]);
    }

    /** POST /attachments/{id}/complete : vérifie l'empreinte, marque synchronisé. */
    public function complete(Request $request, string $id): JsonResponse
    {
        $pj = \App\Models\PieceJointe::query()->findOrFail($id);
        $cle = 'attachments/'.$pj->id;
        if (! Storage::disk('local')->exists($cle)) {
            return $this->erreur('CONTENU_ABSENT', 'Aucun contenu reçu pour cette pièce jointe.', 409);
        }
        $contenu = Storage::disk('local')->get($cle);
        $sha = hash('sha256', $contenu);
        if (strlen($contenu) !== (int) $pj->taille_octets || ! hash_equals(strtolower($pj->sha256), $sha)) {
            Storage::disk('local')->delete($cle);
            return $this->erreur('EMPREINTE_INVALIDE', 'Taille ou SHA-256 du fichier reçu incorrect.', 409);
        }

        return DB::transaction(function () use ($pj, $cle) {
            $pj->cle_stockage_distant = $cle;
            $pj->statut_transfert = 'synchronise';
            $pj->version += 1;
            $pj->save();

            return $this->ok(['id' => $pj->id, 'statut_transfert' => 'synchronise', 'sha256' => $pj->sha256, 'taille_octets' => (int) $pj->taille_octets]);
        });
    }

    /** GET /attachments/{id}/download : téléchargement vers un autre appareil. */
    public function telecharge(string $id)
    {
        $pj = \App\Models\PieceJointe::query()->findOrFail($id);
        if ($pj->statut_transfert !== 'synchronise' || ! $pj->cle_stockage_distant) {
            return response()->json(['error' => ['code' => 'CONTENU_ABSENT', 'message' => 'Fichier pas encore synchronisé côté serveur.', 'details' => null], 'request_id' => request()->attributes->get('request_id')], 404);
        }

        return Storage::disk('local')->download($pj->cle_stockage_distant, $pj->nom_fichier);
    }

    /** GET /attachments : liste paginée (métadonnées). */
    public function index(Request $request): JsonResponse
    {
        $q = \App\Models\PieceJointe::query()->whereNull('deleted_at');
        foreach (['client_id', 'demande_id', 'commande_id', 'projet_id'] as $champ) {
            if ($v = $request->query($champ)) {
                $q->where($champ, $v);
            }
        }
        $q->orderByDesc('created_at');

        return $this->page($request, $q);
    }
}

/** Audit et administration. */
