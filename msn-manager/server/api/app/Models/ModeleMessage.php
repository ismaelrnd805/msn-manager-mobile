<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class ModeleMessage extends Model
{
    use HasUuids;
    use SoftDeletes;

    protected $table = 'modeles_messages';

    protected $fillable = [
        'id',
        'code',
        'nom',
        'objectif',
        'canal',
        'corps_template',
        'variables_json',
        'actif',
    ];

    protected $casts = [
        'actif' => 'boolean',
        'variables_json' => 'array',
    ];

}
