<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Appareil extends Model
{
    use HasUuids;

    protected $table = 'appareils';

    protected $fillable = [
        'id',
        'user_id',
        'nom',
        'plateforme',
        'dernier_sync_at',
        'actif',
    ];

    protected $casts = [
        'actif' => 'boolean',
        'dernier_sync_at' => 'datetime',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
