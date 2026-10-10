<?php

namespace App\Providers;

use Illuminate\Cache\RateLimiting\Limit;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    public function register(): void
    {
        //
    }

    /**
     * Limiteurs de débit par fonction (spec §10 sécurité) :
     *  - auth    : login 5/min par IP ; refresh/logout 30/min par utilisateur
     *  - sync    : 30/min par utilisateur (routes /sync/*)
     *  - métier  : 120/min par utilisateur (clé incluant le chemin → buckets isolés par ressource)
     */
    public function boot(): void
    {
        RateLimiter::for('auth', function (Request $request) {
            if ($request->is('api/v1/auth/login')) {
                return Limit::perMinute(5)->by('login:'.$request->ip());
            }

            return Limit::perMinute(30)->by('auth:'.$request->user()?->id.':'.$request->path());
        });

        RateLimiter::for('sync', function (Request $request) {
            return Limit::perMinute(30)->by('sync:'.$request->user()?->id.':'.$request->path());
        });

        RateLimiter::for('metier', function (Request $request) {
            return Limit::perMinute(240)->by('metier:'.$request->user()?->id.':'.$request->path());
        });
    }
}
