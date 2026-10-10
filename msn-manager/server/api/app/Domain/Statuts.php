<?php

namespace App\Domain;

/**
 * Machines à états autoritaires (spec §4.2, §9 règle 8).
 * Aucune transition hors de ces tableaux n'est acceptée par le serveur.
 */
final class Statuts
{
    public const DEMANDE = [
        'a_qualifier' => ['offre_presentee', 'devis_a_preparer', 'perdue'],
        'offre_presentee' => ['en_attente_client', 'devis_a_preparer', 'perdue'],
        'en_attente_client' => ['devis_a_preparer', 'perdue', 'offre_presentee'],
        'devis_a_preparer' => ['gagnee', 'perdue', 'offre_presentee'],
        'gagnee' => [],
        'perdue' => [],
    ];

    public const DEVIS = [
        'brouillon' => ['presente'],
        'presente' => ['modification_demandee', 'accepte', 'refuse', 'expire'],
        'modification_demandee' => ['remplace'],
        'accepte' => [],
        'refuse' => [],
        'expire' => [],
        'remplace' => [],
    ];

    public const COMMANDE = [
        'en_preparation' => ['en_attente_validation', 'validee', 'annulee'],
        'en_attente_validation' => ['validee', 'annulee'],
        'validee' => ['en_production', 'annulee'],
        'en_production' => ['en_correction', 'livree', 'annulee'],
        'en_correction' => ['en_production', 'livree'],
        'livree' => [],
        'annulee' => [],
    ];

    public const FACTURE = [
        'brouillon' => ['emise', 'annulee'],
        'emise' => ['partiellement_payee', 'payee', 'annulee'], // partiellement_payee/payee écrits par PaiementService uniquement
        'partiellement_payee' => ['payee'],
        'payee' => [],
        'annulee' => [],
    ];

    public const ECHANGE = [
        'brouillon' => ['prete', 'echec'],
        'prete' => ['copiee', 'envoi_manuel_confirme', 'envoi_integration_confirme', 'echec'],
        'copiee' => ['envoi_manuel_confirme', 'echec'],
        'envoi_manuel_confirme' => [],
        'envoi_integration_confirme' => [],
        'echec' => ['prete'],
    ];

    public const PROJET = [
        'en_preparation' => ['en_cours', 'annule'],
        'en_cours' => ['en_correction', 'termine', 'annule'],
        'en_correction' => ['en_cours', 'termine'],
        'termine' => [],
        'annule' => [],
    ];

    public const PUBLICATION_FB = [
        'planifie' => ['prete', 'annule'],
        'prete' => ['publie_manuellement', 'annule'],
        'publie_manuellement' => [],
        'annule' => [],
    ];

    public static function transitionAutorisee(string $domaine, string $de, string $vers): bool
    {
        $map = match ($domaine) {
            'demande' => self::DEMANDE,
            'devis' => self::DEVIS,
            'commande' => self::COMMANDE,
            'facture' => self::FACTURE,
            'echange' => self::ECHANGE,
            'projet' => self::PROJET,
            'publication_facebook' => self::PUBLICATION_FB,
            default => throw new \InvalidArgumentException("Domaine inconnu: $domaine"),
        };

        return in_array($vers, $map[$de] ?? [], true);
    }
}
