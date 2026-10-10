<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Devis extends Model
{
    use HasUuids;
    use SoftDeletes;

    protected $table = 'devis';

    protected $fillable = [
        'id',
        'numero',
        'demande_id',
        'commande_id',
        'revision',
        'statut',
        'date_emission',
        'date_validite',
        'conditions',
        'total_ht',
        'devise',
        'accepte_at',
    ];

    protected $casts = [
        'date_emission' => 'date',
        'date_validite' => 'date',
        'accepte_at' => 'datetime',
    ];

    public function demande()
    {
        return $this->belongsTo(Demande::class);
    }

    public function commande()
    {
        return $this->belongsTo(Commande::class);
    }

    public function lignes()
    {
        return $this->hasMany(LigneDevis::class);
    }
}
