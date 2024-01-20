FROM php:8.2.14-fpm-bullseye
ARG S6_OVERLAY_VERSION=3.1.6.2
# ENV S6_READ_ONLY_ROOT=1
ENV S6_KEEP_ENV=1

RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates nginx procps xz-utils git

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-x86_64.tar.xz

RUN rm -rf /usr/local/etc/php-fpm.d/
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

COPY ./rootfs /
COPY ./php/php-fpm.conf /usr/local/etc/php-fpm.d/php-fpm.conf
COPY ./laravel/ /var/www/laravel/
RUN chown -R www-data:www-data /var/www/laravel/

# Composerインストール
WORKDIR /var/www/laravel
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php -r "if (hash_file('sha384', 'composer-setup.php') === 'e21205b207c3ff031906575712edab6f13eb0b361f2085f1f1237b7126d785e826a450292b6cfd1d64d92e6563bbde02') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
RUN php composer-setup.php
RUN php -r "unlink('composer-setup.php');"
RUN mv composer.phar /usr/local/bin/composer

# 依存ライブラリインストール
ENV COMPOSER_ALLOW_SUPERUSER=1
RUN composer install

EXPOSE 80 443 9000

ENTRYPOINT ["/init"]
