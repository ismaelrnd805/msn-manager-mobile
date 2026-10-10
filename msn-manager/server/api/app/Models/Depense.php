<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Depense extends Model
{
    use HasUuids;
    use SoftDeletes;

    protected $table = 'depenses';

    protected $fillable = [
        'id',
        'date_depense',
        'categorie',
        'description',
        'montant',
        'devise',
        'moyen',
        'reference',
    ];

    protected $casts = [
        'date_depense' => 'date',
    ];

}
