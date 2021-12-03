ARG VERSION=${VERSION:-[VERSION]}

FROM smizy/libsvm AS builder

ARG VERSION

FROM php:${VERSION}-fpm-alpine

ARG VERSION

COPY --from=builder \
    /usr/local/bin/svm-train \
    /usr/local/bin/svm-predict \
    /usr/local/bin/svm-scale \
    /usr/local/bin/

RUN apk update && apk add \
  bash \
  bc \
  postgresql-libs \
  && apk add --virtual .build-deps \
  musl-dev \
  autoconf \
  postgresql-dev \
  && docker-php-ext-install \
  pcntl \
  sockets \
  pdo_pgsql \
  pdo_mysql

# tensor
# svm librar (libgomp, libstdc++, libgcc)
RUN if [[ $(echo "$VERSION >= 7.4" | bc -l) == 1 ]] ; then \
  apk add \
  libgomp \
  libstdc++ \
  libgcc \
  && apk add --virtual .build-deps \ 
  lapack-dev \
  libexecinfo-dev \
  openblas-dev \
  ; fi

# xdebug
# git use in php-coveralls/php-coveralls
RUN if [[ $(echo "$VERSION >= 7.2" | bc -l) == 1 ]] ; then \
  apk add \
  git \
  && apk add --no-cache --virtual .phpize-deps $PHPIZE_DEPS \
  && pecl install xdebug-3.1.1 \
  && docker-php-ext-enable xdebug \
  && apk del -f .phpize-deps \
  ; fi

# nodejs
COPY ./cacert.pem /usr/local/share/ca-certificates/cacert.pem
RUN if [[ $(echo "$VERSION == 7.0" | bc -l) == 1 ]] ; then apk add nodejs yarn; \
  elif [[ $(echo "$VERSION == 5.5" | bc -l) == 1 ]] ; then apk --no-cache add nodejs ca-certificates && update-ca-certificates; \
  else apk add nodejs npm yarn; fi

# clean
RUN apk del -f .build-deps && rm -rf /var/cache/apk/*

ENV COMPOSER_HOME=/.composer \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \ 
    LC_ALL=en_US.UTF-8 \
    PATH=$PATH:./node_modules/.bin:./vendor/bin

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php -r "if (hash_file('sha384', 'composer-setup.php') === '906a84df04cea2aa72f40b5f787e49f22d4c2f19492ac310e8cba5b96ac8b64115ac402c8cd292b8a03482574915d1a8') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
    && php composer-setup.php \
    && php -r "unlink('composer-setup.php');" \
    && mv composer.phar /usr/local/bin/composer

RUN if [[ $(echo "$VERSION <= 7.1" | bc -l) == 1 ]] ; then composer global require phpunit/phpunit 4.8.36 ; \
  elif [[ $(echo "$VERSION <= 7.4" | bc -l) == 1 ]] ; then composer global require phpunit/phpunit 6.5.14 ; \
  else composer global require --ignore-platform-req=php \
    phpunit/phpunit 9.5.10 \
    symfony/console 5.*.* \
    php-coveralls/php-coveralls \
    && ln -s /.composer/vendor/bin/php-coveralls /usr/local/bin/coveralls \
  ; fi; \
  composer global require pmvc/pmvc-cli:^0.5.5 \
  && chmod 0777 /.composer \
  && chmod 0777 -R /.composer/cache \
  && ln -s /.composer/vendor/bin/pmvc /usr/local/bin/ \
  && ln -s /.composer/vendor/bin/phpunit /usr/local/bin/

# fixed timezone
# https://stackoverflow.com/questions/45587214/configure-timezone-in-dockerized-nginx-php-fpm/45587945
RUN printf '[PHP]\ndate.timezone = "UTC"\n' > /usr/local/etc/php/conf.d/tzone.ini

VOLUME ["/.composer"]
WORKDIR /var/www/html
