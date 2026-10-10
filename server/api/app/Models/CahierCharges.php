<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class CahierCharges extends Model
{
    use HasUuids;
    use SoftDeletes;

    protected $table = 'cahiers_charges';

    protected $fillable = [
        'id',
        'projet_id',
        'version_document',
        'contenu_json',
        'statut',
        'date_validation',
    ];

    protected $casts = [
        'contenu_json' => 'array',
    ];

    public function projet()
    {
        return $this->belongsTo(Projet::class);
    }
}
