# 05 — Backend NestJS attendu (spécification)

Le mobile est déjà branché sur les contrats ci-dessous (`lib/core/sync/api_client.dart`, `api_contracts.dart`). **Aucun serveur n'est requis pour faire tourner l'application** : tant que `server_url` n'est pas configurée, tout reste local. Le backend cible est NestJS + PostgreSQL, exposé sous `/api/v1`.

## 1. Contrats consommés par le mobile

| Endpoint | Méthode | Requête | Réponse |
|---|---|---|---|
| `/api/v1/auth/login` | POST | `{"username": "...", "password": "..."}` | `{"accessToken": "...", "refreshToken": "..."}` |
| `/api/v1/sync/batch` | POST | `{"deviceId": "...", "changes": [SyncPayload]}` | `{"accepted": ["<entityId>", …], "conflicts": ["<entityId>", …]}` |
| `/api/v1/sync/changes?since=<ISO8601>` | GET | header `Authorization: Bearer` | `{"changes": [RemoteChange]}` |
| `/api/v1/health` | GET | — | 200 (ping, timeout 5 s côté mobile) |

Forme d'un `SyncPayload` (push) :

```json
{
  "entite": "clients",
  "entityId": "cli_1730000000000",
  "operation": "create",
  "payload": {"nom": "Jean Rakoto", "telephone": "034 12 345 67"},
  "updatedAt": "2026-01-05T09:30:00.000",
  "deviceId": "mobile-1730000000000"
}
```

Forme d'un `RemoteChange` (pull) :

```json
{
  "entite": "clients",
  "entityId": "cli_1730000000000",
  "payload": {"nom": "Jean Rakoto", "telephone": "034 12 345 67"},
  "updatedAt": "2026-01-06T08:00:00.000Z",
  "version": 42
}
```

`operation` ∈ `create | update | delete` (noms d'enum `SyncOperation`), `entite` = nom de table (ex. `clients`, `requests`, `orders`, `invoices`, `payments`…). Les IDs acceptés/renvoyés en conflit sont des **entityId** (le mobile les relie à ses lignes de file).

## 2. Schéma serveur de la synchronisation

Table centrale `sync_log` (une ligne par changement reçu ou diffusé) :

```sql
CREATE TABLE sync_log (
  id           BIGSERIAL PRIMARY KEY,
  entite       TEXT        NOT NULL,
  entity_id    TEXT        NOT NULL,
  operation    TEXT        NOT NULL CHECK (operation IN ('create','update','delete')),
  payload      JSONB       NOT NULL,
  device_id    TEXT        NOT NULL,
  version      BIGINT      NOT NULL,       -- compteur croissant (global ou par entité)
  client_updated_at TIMESTAMPTZ NOT NULL,   -- updatedAt déclaré par l'appareil
  server_updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (entite, entity_id, version)
);
CREATE INDEX ON sync_log (entite, entity_id, server_updated_at DESC);
```

- `since` du pull filtre sur `server_updated_at > since` ; `version` ordonne strictement les changements.
- Le dernier état de chaque entité peut être matérialisé dans une table `sync_state (entite, entity_id, version, updated_at, device_id)` pour accélérer la comparaison.
- Les payloads sont stockés tels quels (JSONB) : le serveur n'a pas besoin du modèle métier complet pour la phase 1.

## 3. Résolution des conflits côté serveur

Règle : **jamais d'écrasement silencieux**. À réception d'un changement :

1. Charger l'état courant (`sync_state`) pour `(entite, entity_id)`.
2. Si aucun état : accepter (INSERT), incrémenter `version`.
3. Si état existant :
   - `client_updated_at` entrant **>** `server_updated_at` stocké -> accepter, `version + 1`.
   - sinon -> ne rien écrire, renvoyer l'`entityId` dans `conflicts` ; le mobile crée le conflit local (`sync_conflicts`) pour décision humaine (garder local / garder distant).
4. Les conflits peuvent aussi être journalisés serveur (`sync_conflict_log`) pour audit inter-appareils.

Le mobile applique la règle miroir : un pull touchant une entité avec écriture locale en attente est refusé et pose un conflit local.

## 4. Structure NestJS

```
src/
  main.ts                     # global prefix 'api/v1', ValidationPipe global
  app.module.ts
  auth/
    auth.module.ts
    auth.controller.ts        # POST /auth/login, POST /auth/refresh
    auth.service.ts           # bcrypt + JwtService (access 15 min, refresh 7 j)
    jwt-auth.guard.ts
    dto/login.dto.ts
  sync/
    sync.module.ts
    sync.controller.ts        # POST /sync/batch, GET /sync/changes, GET /health
    sync.service.ts           # lot transactionnel, versions, conflits
    dto/push-batch.dto.ts
    dto/sync-payload.dto.ts
  prisma/ (ou typeorm/)       # accès PostgreSQL
```

DTOs principaux (class-validator) :

```typescript
// dto/sync-payload.dto.ts
export class SyncPayloadDto {
  @IsString() entite: string;
  @IsString() entityId: string;
  @IsIn(['create', 'update', 'delete']) operation: string;
  @IsObject() payload: Record<string, any>;
  @IsDateString() updatedAt: string;
  @IsString() deviceId: string;
}

// dto/push-batch.dto.ts
export class PushBatchDto {
  @IsString() deviceId: string;
  @ValidateNested({ each: true }) @Type(() => SyncPayloadDto)
  changes: SyncPayloadDto[];
}
```

Contrôleur (extrait) :

```typescript
@UseGuards(JwtAuthGuard)
@Controller('sync')
export class SyncController {
  @Post('batch')
  async batch(@Body() dto: PushBatchDto) {
    return this.syncService.applyBatch(dto); // { accepted: [], conflicts: [] }
  }

  @Get('changes')
  async changes(@Query('since', ParseISODateTimePipe) since: Date) {
    return { changes: await this.syncService.changesSince(since) };
  }

  @Get('health') health() { return { status: 'ok' }; }
}
```

`auth/login` : identifiants métier (même logique que les comptes mobile : PIN/admin), retourne access + refresh JWT ; le mobile enverra `Authorization: Bearer <accessToken>` (champ déjà prévu dans `ApiClient._headers`).

## 5. Déploiement — stratégie LAN d'abord

1. **Phase 1 (LAN)** : serveur NestJS + PostgreSQL sur un poste du boutique (`http://192.168.x.x:3000`), URL saisie dans l'écran Paramètres du mobile. Aucune exposition Internet, aucun coût, suffisant pour la sync quotidienne sur le wifi du local.
2. **Phase 2 (multi-sites)** : VPS avec reverse proxy (Nginx/Caddy) et **HTTPS obligatoire** ; rotation des refresh tokens ; sauvegardes PostgreSQL.
3. **Phase 3 (temps réel)** : WebSocket ou FCM pour « pousser » les pulls (optionnel : le polling 5 min du mobile suffit en v1).

Le mobile tolère totalement l'indisponibilité : échec réseau = file conservée, nouvelles tentatives au cycle suivant.
