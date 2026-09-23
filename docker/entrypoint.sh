#!/bin/sh
set -eu

mkdir -p storage/app/public \
    storage/framework/cache \
    storage/framework/sessions \
    storage/framework/views \
    bootstrap/cache

chown -R www-data:www-data storage bootstrap/cache
chmod -R ug+rwx storage bootstrap/cache

if [ -L public/storage ]; then
    :
elif [ -e public/storage ]; then
    printf '%s\n' 'public/storage exists and is not a symlink; refusing to replace it.' >&2
    exit 1
else
    php artisan storage:link
fi

exec "$@"
