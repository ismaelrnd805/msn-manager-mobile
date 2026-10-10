<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Commande extends Model
{
    use HasUuids;
    use SoftDeletes;

    protected $table = 'commandes';

    protected $fillable = [
        'id',
        'numero',
        'demande_id',
        'statut',
        'date_confirmation',
        'date_debut_prevue',
        'date_limite_confirmee',
        'instructions',
        'motif_annulation',
    ];

    protected $casts = [
        'date_confirmation' => 'datetime',
        'date_debut_prevue' => 'date',
        'date_limite_confirmee' => 'date',
    ];

    public function demande()
    {
        return $this->belongsTo(Demande::class);
    }

    public function lignes()
    {
        return $this->hasMany(LigneCommande::class);
    }

    public function projets()
    {
        return $this->hasMany(Projet::class);
    }

    public function taches()
    {
        return $this->hasMany(Tache::class);
    }

    public function facture()
    {
        return $this->hasOne(Facture::class);
    }

    public function devis()
    {
        return $this->hasMany(Devis::class);
    }
}
