<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class PieceJointe extends Model
{
    use HasUuids;
    use SoftDeletes;

    protected $table = 'piece_jointes';

    protected $fillable = [
        'id',
        'client_id',
        'demande_id',
        'commande_id',
        'projet_id',
        'nom_fichier',
        'mime_type',
        'taille_octets',
        'sha256',
        'chemin_local',
        'cle_stockage_distant',
        'statut_transfert',
    ];

    protected $casts = [
        //
    ];

    public function client()
    {
        return $this->belongsTo(Client::class);
    }

    public function demande()
    {
        return $this->belongsTo(Demande::class);
    }

    public function commande()
    {
        return $this->belongsTo(Commande::class);
    }

    public function projet()
    {
        return $this->belongsTo(Projet::class);
    }
}
