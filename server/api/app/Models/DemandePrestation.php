<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class DemandePrestation extends Model
{
    use HasUuids;
    use SoftDeletes;

    protected $table = 'demande_prestations';

    protected $fillable = [
        'id',
        'demande_id',
        'service_id',
        'quantite',
        'unite_snapshot',
        'prix_indicatif_unitaire',
        'devise',
        'details_json',
    ];

    protected $casts = [
        'details_json' => 'array',
    ];

    public function demande()
    {
        return $this->belongsTo(Demande::class);
    }

    public function service()
    {
        return $this->belongsTo(Service::class);
    }
}
