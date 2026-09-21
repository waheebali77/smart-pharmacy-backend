<?php

namespace App\Exceptions;

use RuntimeException;

class PharmacySubscriptionExpiredException extends RuntimeException
{
    public const MESSAGE = 'انتهت فترتك التجريبية، يرجى سداد الاشتراك لتفعيل حسابك';

    public function __construct()
    {
        parent::__construct(self::MESSAGE);
    }
}
