<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Client extends Model
{
    use HasUuids;
    use SoftDeletes;

    protected $table = 'clients';

    protected $fillable = [
        'id',
        'type_client',
        'nom_affiche',
        'nom_legal',
        'telephone_principal',
        'email_principal',
        'adresse',
        'notes',
        'actif',
    ];

    protected $casts = [
        'actif' => 'boolean',
    ];

    public function contacts()
    {
        return $this->hasMany(Contact::class);
    }

    public function demandes()
    {
        return $this->hasMany(Demande::class);
    }

    public function echanges()
    {
        return $this->hasMany(Echange::class);
    }

    public function pieces_jointes()
    {
        return $this->hasMany(PieceJointe::class);
    }
}
