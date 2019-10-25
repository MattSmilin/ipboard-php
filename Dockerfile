FROM php:7.3-fpm-alpine

# Required and recommended libraries (2 layers)
# GD
RUN apk add --no-cache libpng-dev libjpeg-turbo-dev libzip-dev freetype-dev && \
   docker-php-ext-configure gd \
   --with-gd \
   --with-freetype-dir=/usr/include/ \
   --with-png-dir=/usr/include/ \
   --with-jpeg-dir=/usr/include/ && \
   NPROC=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) && \
   docker-php-ext-install -j${NPROC} gd
# Other php extensions
RUN docker-php-ext-install mysqli zip exif

# Memcached
# Comment this section out if You are not planning to use it
ENV MEMCACHED_DEPS zlib-dev libmemcached-dev cyrus-sasl-dev
RUN apk add --no-cache --update libmemcached-libs zlib
RUN set -xe \
   && apk add --no-cache --update --virtual .phpize-deps $PHPIZE_DEPS \
   && apk add --no-cache --update --virtual .memcached-deps $MEMCACHED_DEPS \
   && pecl install memcached \
   && echo "extension=memcached.so" > /usr/local/etc/php/conf.d/20_memcached.ini \
   && rm -rf /usr/share/php7 \
   && rm -rf /tmp/* \
   && apk del .memcached-deps .phpize-deps

CMD ["php-fpm"]