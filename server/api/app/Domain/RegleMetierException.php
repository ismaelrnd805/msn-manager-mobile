<?php

namespace App\Domain;

/**
 * Conflit de version optimiste (HTTP 409 VERSION_CONFLICT).
 * Porte l'état serveur courant pour permettre la résolution auditable (spec §8.5).
 */

final class RegleMetierException extends \RuntimeException
{
    public function __construct(public readonly string $codeErreur, string $message)
    {
        parent::__construct($message);
    }

    public function getErreurCode(): string
    {
        return $this->codeErreur;
    }
}
