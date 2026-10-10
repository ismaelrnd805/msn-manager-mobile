<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * Contrôleur de base : format d'erreur JSON structuré avec code + request_id (spec §7),
 * pagination bornée pour toutes les listes.
 */
abstract class ApiController extends Controller
{
    protected function ok($data, int $http = 200): JsonResponse
    {
        return response()->json(['data' => $data], $http);
    }

    protected function erreur(string $code, string $message, int $http, ?array $details = null): JsonResponse
    {
        return response()->json([
            'error' => ['code' => $code, 'message' => $message, 'details' => $details],
            'request_id' => request()->attributes->get('request_id'),
        ], $http);
    }

    /** Pagination bornée : jamais de liste illimitée (spec §7.2). */
    protected function page(Request $request, $query, int $maxParPage = 100): JsonResponse
    {
        $parPage = min(max((int) $request->query('per_page', 25), 1), $maxParPage);
        $page = max((int) $request->query('page', 1), 1);
        $total = (clone $query)->count();
        $items = $query->forPage($page, $parPage)->get();

        return response()->json([
            'data' => $items,
            'pagination' => ['page' => $page, 'per_page' => $parPage, 'total' => $total,
                'pages' => (int) ceil($total / max($parPage, 1))],
        ]);
    }
}
