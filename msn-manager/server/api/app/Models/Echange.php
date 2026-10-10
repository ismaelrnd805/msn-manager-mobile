<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Echange extends Model
{
    use HasUuids;
    use SoftDeletes;

    protected $table = 'echanges';

    protected $fillable = [
        'id',
        'client_id',
        'demande_id',
        'commande_id',
        'modele_id',
        'canal',
        'direction',
        'contenu',
        'statut_envoi',
        'date_preparation',
        'date_copie',
        'date_envoi_confirme',
        'external_reference',
    ];

    protected $casts = [
        'date_preparation' => 'datetime',
        'date_copie' => 'datetime',
        'date_envoi_confirme' => 'datetime',
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

    public function modelemessage()
    {
        return $this->belongsTo(ModeleMessage::class);
    }
}
