<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed les données initiales : catalogue V1 (versionné).
     */
    public function run(): void
    {
        $this->call(CatalogueSeeder::class);
    }
}
