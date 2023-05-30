FROM php:8.1.9-fpm-alpine
RUN apk --no-cache upgrade && \
    apk --no-cache add bash git sudo openssh  libxml2-dev oniguruma-dev autoconf gcc g++ make npm freetype-dev libjpeg-turbo-dev libpng-dev libzip-dev

# PHP: Instala extensiones de PHP
RUN apk add libssh2-dev
RUN pecl channel-update pecl.php.net
RUN pecl install pcov ssh2 swoole
RUN docker-php-ext-configure gd --with-freetype --with-jpeg
RUN docker-php-ext-install mbstring xml  pcntl gd zip sockets pdo pdo_mysql bcmath soap
RUN docker-php-ext-enable mbstring xml gd  zip pcov pcntl sockets bcmath pdo  pdo_mysql soap swoole

RUN docker-php-ext-install pdo pdo_mysql sockets
RUN curl -sS https://getcomposer.org/installer | php -- \
     --install-dir=/usr/local/bin --filename=composer

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
COPY --from=spiralscout/roadrunner:2.4.2 /usr/bin/rr /usr/bin/rr

WORKDIR /app
COPY . .

RUN composer install
RUN composer require laravel/octane spiral/roadrunner
RUN composer require pusher/pusher-php-server
RUN composer require beyondcode/laravel-websockets

RUN npm install --global yarn
RUN npm install --save-dev laravel-echo pusher-js@7.0.0
RUN yarn add postcss@latest

RUN yarn
RUN yarn build

RUN php artisan key:generate
RUN php artisan octane:install --server="swoole"

CMD php artisan octane:start --server="swoole" --host="0.0.0.0" & php artisan websockets:serve
EXPOSE 8000 6001
