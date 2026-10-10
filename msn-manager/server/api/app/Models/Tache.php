<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Tache extends Model
{
    use HasUuids;
    use SoftDeletes;

    protected $table = 'taches';

    protected $fillable = [
        'id',
        'commande_id',
        'projet_id',
        'titre',
        'description',
        'statut',
        'priorite',
        'echeance',
        'terminee_at',
    ];

    protected $casts = [
        'echeance' => 'datetime',
        'terminee_at' => 'datetime',
    ];

    public function commande()
    {
        return $this->belongsTo(Commande::class);
    }

    public function projet()
    {
        return $this->belongsTo(Projet::class);
    }
}
