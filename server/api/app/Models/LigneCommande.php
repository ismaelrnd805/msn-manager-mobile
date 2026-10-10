<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class LigneCommande extends Model
{
    use HasUuids;
    use SoftDeletes;

    protected $table = 'lignes_commande';

    protected $fillable = [
        'id',
        'commande_id',
        'service_id',
        'description',
        'quantite',
        'unite_snapshot',
        'prix_unitaire',
        'devise',
    ];

    protected $casts = [
        //
    ];

    public function commande()
    {
        return $this->belongsTo(Commande::class);
    }

    public function service()
    {
        return $this->belongsTo(Service::class);
    }
}
