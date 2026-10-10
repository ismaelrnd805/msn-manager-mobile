<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Contact extends Model
{
    use HasUuids;
    use SoftDeletes;

    protected $table = 'contacts';

    protected $fillable = [
        'id',
        'client_id',
        'nom',
        'role',
        'telephone',
        'email',
        'canal_prefere',
        'principal',
    ];

    protected $casts = [
        'principal' => 'boolean',
    ];

    public function client()
    {
        return $this->belongsTo(Client::class);
    }
}
