<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Facture extends Model
{
    use HasUuids;
    use SoftDeletes;

    protected $table = 'factures';

    protected $fillable = [
        'id',
        'numero',
        'commande_id',
        'statut',
        'date_emission',
        'date_echeance',
        'total',
        'devise',
        'conditions',
    ];

    protected $casts = [
        'date_emission' => 'date',
        'date_echeance' => 'date',
    ];

    public function commande()
    {
        return $this->belongsTo(Commande::class);
    }

    public function lignes()
    {
        return $this->hasMany(LigneFacture::class);
    }

    public function paiements()
    {
        return $this->hasMany(Paiement::class);
    }
}
