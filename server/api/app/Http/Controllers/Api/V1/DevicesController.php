<?php

namespace App\Http\Controllers\Api\V1;

use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use App\Models\Appareil;
/** Enregistrement / révocation d'appareils (spec §7.1). */
final class DevicesController extends ApiController
{
    public function register(Request $request): JsonResponse
    {
        $d = $request->validate([
            'device_id' => ['required', 'uuid'],
            'nom' => ['required', 'string', 'max:120'],
            'plateforme' => ['required', 'in:android,windows'],
        ]);
        $a = Appareil::query()->updateOrCreate(
            ['id' => $d['device_id']],
            ['user_id' => $request->user()->id, 'nom' => $d['nom'], 'plateforme' => $d['plateforme'], 'actif' => true],
        );

        return $this->ok(['id' => $a->id, 'nom' => $a->nom, 'plateforme' => $a->plateforme], 201);
    }

    public function revoke(string $deviceId, Request $request): JsonResponse
    {
        $a = Appareil::query()->where('id', $deviceId)->where('user_id', $request->user()->id)->firstOrFail();
        $a->actif = false;
        $a->save();

        return $this->ok(['id' => $a->id, 'actif' => false, 'message' => 'Appareil révoqué.']);
    }
}
