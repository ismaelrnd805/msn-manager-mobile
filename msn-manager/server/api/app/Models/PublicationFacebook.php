<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class PublicationFacebook extends Model
{
    use HasUuids;
    use SoftDeletes;

    protected $table = 'publications_facebook';

    protected $fillable = [
        'id',
        'client_id',
        'titre',
        'contenu',
        'date_planifiee',
        'statut',
        'canal',
        'publie_at',
        'notes',
    ];

    protected $casts = [
        'date_planifiee' => 'date',
        'publie_at' => 'datetime',
    ];

    public function client()
    {
        return $this->belongsTo(Client::class);
    }
}
