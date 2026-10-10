<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Projet extends Model
{
    use HasUuids;
    use SoftDeletes;

    protected $table = 'projets';

    protected $fillable = [
        'id',
        'commande_id',
        'nom',
        'description',
        'statut',
        'date_limite',
    ];

    protected $casts = [
        'date_limite' => 'date',
    ];

    public function commande()
    {
        return $this->belongsTo(Commande::class);
    }

    public function cahiers_charges()
    {
        return $this->hasMany(CahierCharges::class);
    }
}
