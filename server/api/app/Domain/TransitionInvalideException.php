<?php

namespace App\Domain;

/**
 * Conflit de version optimiste (HTTP 409 VERSION_CONFLICT).
 * Porte l'état serveur courant pour permettre la résolution auditable (spec §8.5).
 */

final class TransitionInvalideException extends \RuntimeException
{
    public function __construct(string $entiteType, string $de, string $vers)
    {
        parent::__construct("Transition $de → $vers interdite pour $entiteType.");
    }
}

/** Violation d'une règle métier (HTTP 409 REGLE_METIER). */
