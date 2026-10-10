<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Service extends Model
{
    use HasUuids;
    use SoftDeletes;

    protected $table = 'services';

    protected $fillable = [
        'id',
        'code',
        'nom',
        'description',
        'categorie',
        'unite_tarifaire',
        'actif',
        'necessite_cahier_charges',
        'questions_qualification_json',
    ];

    protected $casts = [
        'actif' => 'boolean',
        'necessite_cahier_charges' => 'boolean',
        'questions_qualification_json' => 'array',
    ];

    public function tarifs()
    {
        return $this->hasMany(Tarif::class);
    }
}
