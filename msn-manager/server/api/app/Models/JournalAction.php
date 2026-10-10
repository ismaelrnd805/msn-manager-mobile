<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class JournalAction extends Model
{
    use HasUuids;

    protected $table = 'journal_actions';

    protected $fillable = [
        'id',
        'entite_type',
        'entite_id',
        'action',
        'avant_json',
        'apres_json',
        'motif',
        'appareil_id',
        'acteur_id',
        'date_action',
    ];

    protected $casts = [
        'date_action' => 'datetime',
        'avant_json' => 'array',
        'apres_json' => 'array',
    ];

}
