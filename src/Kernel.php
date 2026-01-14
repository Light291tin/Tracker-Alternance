<?php

namespace App;

use Symfony\Bundle\FrameworkBundle\Kernel\MicroKernelTrait;
use Symfony\Component\HttpKernel\Kernel as BaseKernel;

class Kernel extends BaseKernel
{
    use MicroKernelTrait;

    // Force le cache dans /tmp pour éviter les erreurs de permission sur Render
    public function getCacheDir(): string
{
    return '/tmp/cache/'.$this->environment;
}

public function getLogDir(): string
{
    return '/tmp/logs';
}
}