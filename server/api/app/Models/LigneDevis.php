<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class LigneDevis extends Model
{
    use HasUuids;
    use SoftDeletes;

    protected $table = 'lignes_devis';

    protected $fillable = [
        'id',
        'devis_id',
        'service_id',
        'description',
        'quantite',
        'unite_snapshot',
        'prix_unitaire',
        'montant_ligne',
    ];

    protected $casts = [
        //
    ];

    public function devis()
    {
        return $this->belongsTo(Devis::class);
    }

    public function service()
    {
        return $this->belongsTo(Service::class);
    }
}
