<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Tarif extends Model
{
    use HasUuids;
    use SoftDeletes;

    protected $table = 'tarifs';

    protected $fillable = [
        'id',
        'service_id',
        'prix_unitaire',
        'devise',
        'date_debut_validite',
        'date_fin_validite',
        'actif',
    ];

    protected $casts = [
        'actif' => 'boolean',
        'date_debut_validite' => 'date',
        'date_fin_validite' => 'date',
    ];

    public function service()
    {
        return $this->belongsTo(Service::class);
    }
}
