<?php

use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;
use Illuminate\Http\Request;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        api: __DIR__.'/../routes/api.php',
        apiPrefix: 'api/v1',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware): void {
        $middleware->api(prepend: [
            App\Http\Middleware\RequestId::class,
        ]);

        // API pure : jamais de redirection vers une route 'login' web —
        // évite l'échec anticipé de route('login') quand Accept n'est pas application/json.
        Illuminate\Auth\Middleware\Authenticate::redirectUsing(
            fn (Request $request) => null,
        );
    })
    ->withExceptions(function (Exceptions $exceptions): void {
        $exceptions->shouldRenderJsonWhen(
            fn (Request $request) => $request->is('api/*') || $request->expectsJson(),
        );

        // Format d'erreur JSON structuré (spec §7) : { error: { code, message, details }, request_id }
        $exceptions->render(function (Throwable $e, Request $request) {
            file_put_contents('/tmp/trace2.log', get_class($e).'|'.$request->getPathInfo().'|'.PHP_EOL, FILE_APPEND);
            if (! $request->is('api/*')) {
                return null;
            }
            $requestId = $request->attributes->get('request_id');

            return match (true) {
                $e instanceof Illuminate\Auth\AuthenticationException => response()->json([
                    'error' => ['code' => 'NON_AUTHENTIFIE', 'message' => 'Authentification requise.', 'details' => null], 'request_id' => $requestId,
                ], 401),
                $e instanceof Illuminate\Auth\Access\AuthorizationException => response()->json([
                    'error' => ['code' => 'ACCES_INTERDIT', 'message' => $e->getMessage(), 'details' => null], 'request_id' => $requestId,
                ], 403),
                $e instanceof Illuminate\Database\Eloquent\ModelNotFoundException => response()->json([
                    'error' => ['code' => 'RESSOURCE_INTROUVABLE', 'message' => 'Ressource inexistante.', 'details' => null], 'request_id' => $requestId,
                ], 404),
                $e instanceof Illuminate\Validation\ValidationException => response()->json([
                    'error' => ['code' => 'VALIDATION_ERROR', 'message' => 'Les données envoyées sont invalides.', 'details' => $e->errors()], 'request_id' => $requestId,
                ], 422),
                $e instanceof Illuminate\Http\Exceptions\ThrottleRequestsException => response()->json([
                    'error' => ['code' => 'LIMITE_DEBIT', 'message' => 'Trop de requêtes, réessayez plus tard.', 'details' => null], 'request_id' => $requestId,
                ], 429),
                default => null, // erreurs internes : réponse standard Laravel (trace non exposée en prod)
            };
        });
    })->create();
