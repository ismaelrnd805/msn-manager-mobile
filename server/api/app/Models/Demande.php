<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Demande extends Model
{
    use HasUuids;
    use SoftDeletes;

    protected $table = 'demandes';

    protected $fillable = [
        'id',
        'client_id',
        'contact_id',
        'canal_origine',
        'message_initial',
        'besoin_resume',
        'statut',
        'date_limite_souhaitee',
        'budget_indicatif',
        'devise_budget',
        'motif_perte',
    ];

    protected $casts = [
        'date_limite_souhaitee' => 'date',
    ];

    public function client()
    {
        return $this->belongsTo(Client::class);
    }

    public function contact()
    {
        return $this->belongsTo(Contact::class);
    }

    public function prestations()
    {
        return $this->hasMany(DemandePrestation::class);
    }

    public function devis()
    {
        return $this->hasMany(Devis::class);
    }

    public function commande()
    {
        return $this->hasOne(Commande::class);
    }

    public function echanges()
    {
        return $this->hasMany(Echange::class);
    }
}
