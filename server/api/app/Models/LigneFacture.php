<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class LigneFacture extends Model
{
    use HasUuids;
    use SoftDeletes;

    protected $table = 'lignes_facture';

    protected $fillable = [
        'id',
        'facture_id',
        'description',
        'quantite',
        'unite_snapshot',
        'prix_unitaire',
        'montant_ligne',
    ];

    protected $casts = [
        //
    ];

    public function facture()
    {
        return $this->belongsTo(Facture::class);
    }
}
