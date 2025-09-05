<?php

return [
    'paths' => ['api/*', 'sanctum/csrf-cookie'],
    'allowed_methods' => ['*'],
    'allowed_origins' => [
        'https://bankqu.ekagalang.my.id',
        'http://bankqu.ekagalang.my.id'
    ],
    'allowed_origins_patterns' => [
        'https://*.ekagalang.my.id'
    ],
    'allowed_headers' => ['*'],
    'exposed_headers' => ['X-XSRF-TOKEN'],
    'max_age' => 0,
    'supports_credentials' => true,
];
