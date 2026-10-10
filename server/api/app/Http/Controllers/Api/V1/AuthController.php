<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;
use App\Models\Appareil;
use App\Models\User;

/** Authentification : login, renouvellement de session, révocation (spec §7.1). */
final class AuthController extends Controller
{
    public function login(Request $request): JsonResponse
    {
        $donnees = $request->validate([
            'email' => ['required', 'email'],
            'password' => ['required', 'string'],
            'device_id' => ['required', 'uuid'],
            'device_name' => ['required', 'string', 'max:120'],
            'plateforme' => ['required', 'in:android,windows'],
        ]);

        $user = User::query()->where('email', $donnees['email'])->first();
        if ($user === null || ! Hash::check($donnees['password'], $user->password)) {
            return $this->erreur('AUTH_INVALIDE', 'Identifiants invalides.', 401);
        }

        // Appareil enregistré/rattaché à l'utilisateur (révocation par appareil possible)
        $appareil = Appareil::query()->updateOrCreate(
            ['id' => $donnees['device_id']],
            ['user_id' => $user->id, 'nom' => $donnees['device_name'], 'plateforme' => $donnees['plateforme'], 'actif' => true],
        );

        // Jeton d'accès court (8 h) + jeton de renouvellement (30 jours) — Sanctum
        $accessToken = $user->createToken('access-'.$donnees['device_id'], ['access'], now()->addHours(8))->plainTextToken;
        $refreshToken = $user->createToken('refresh-'.$donnees['device_id'], ['refresh'], now()->addDays(30))->plainTextToken;

        return response()->json([
            'data' => [
                'access_token' => $accessToken,
                'token_type' => 'Bearer',
                'expires_in' => 8 * 3600,
                'refresh_token' => $refreshToken,
                'user' => ['id' => $user->id, 'name' => $user->name, 'email' => $user->email],
                'device' => ['id' => $appareil->id, 'nom' => $appareil->nom, 'plateforme' => $appareil->plateforme],
            ],
        ], 200);
    }

    public function refresh(Request $request): JsonResponse
    {
        $user = $request->user();
        $jetonCourant = $request->user()->currentAccessToken();
        $estRefresh = $jetonCourant && in_array('refresh', $jetonCourant->abilities ?? [], true);
        if (! $estRefresh) {
            return $this->erreur('JETON_INVALIDE', 'Un jeton de renouvellement valide est requis.', 401);
        }
        $deviceId = str($jetonCourant->name)->after('refresh-')->toString();

        $jetonCourant->delete(); // rotation : l'ancien refresh est révoqué
        $accessToken = $user->createToken('access-'.$deviceId, ['access'], now()->addHours(8))->plainTextToken;
        $refreshToken = $user->createToken('refresh-'.$deviceId, ['refresh'], now()->addDays(30))->plainTextToken;

        return response()->json(['data' => [
            'access_token' => $accessToken,
            'token_type' => 'Bearer',
            'expires_in' => 8 * 3600,
            'refresh_token' => $refreshToken,
        ]], 200);
    }

    public function logout(Request $request): JsonResponse
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json(['data' => ['message' => 'Session révoquée.']], 200);
    }

    private function erreur(string $code, string $message, int $http): JsonResponse
    {
        return response()->json([
            'error' => ['code' => $code, 'message' => $message, 'details' => null],
            'request_id' => request()->attributes->get('request_id'),
        ], $http);
    }
}
