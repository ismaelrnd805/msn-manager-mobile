<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Paiement extends Model
{
    use HasUuids;
    use SoftDeletes;

    protected $table = 'paiements';

    protected $fillable = [
        'id',
        'facture_id',
        'montant',
        'devise',
        'date_paiement',
        'moyen',
        'reference',
        'statut',
        'notes',
        'idempotency_key',
    ];

    protected $casts = [
        'date_paiement' => 'date',
    ];

    public function facture()
    {
        return $this->belongsTo(Facture::class);
    }
}
