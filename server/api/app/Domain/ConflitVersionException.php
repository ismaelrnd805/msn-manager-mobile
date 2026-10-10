<?php

namespace App\Domain;

/**
 * Conflit de version optimiste (HTTP 409 VERSION_CONFLICT).
 * Porte l'état serveur courant pour permettre la résolution auditable (spec §8.5).
 */

final class ConflitVersionException extends \RuntimeException
{
    public function __construct(
        public readonly string $entiteType,
        public readonly string $entiteId,
        public readonly int $versionServeur,
        public readonly array $etatServeur,
    ) {
        parent::__construct("Conflit de version sur $entiteType/$entiteId : version serveur = $versionServeur.");
    }
}

/** Transition non autorisée par la machine à états (HTTP 409 INVALID_TRANSITION). */
