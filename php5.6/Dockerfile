ARG VERSION=${VERSION:-5.6}

FROM smizy/libsvm AS builder

ARG VERSION

FROM php:${VERSION}-fpm-alpine

ARG VERSION

COPY --from=builder \
    /usr/local/bin/svm-train \
    /usr/local/bin/

COPY --from=builder \
    /usr/local/bin/svm-predict \
    /usr/local/bin/

COPY --from=builder \
    /usr/local/bin/svm-scale \
    /usr/local/bin/

RUN apk update

# tensor
RUN apk add --virtual .build-deps musl-dev \
  && if [[ "x$VERSION" != "x5.6" ]] ; then \
  apk add --virtual .build-deps \ 
  lapack-dev \
  libexecinfo-dev \
  openblas-dev \
  ; fi

RUN apk add \ 
  bash \
  && docker-php-ext-install \
  pcntl \
  sockets

# svm library
RUN apk add \ 
  libgomp \
  libstdc++ \
  libgcc

# nodejs
RUN apk add nodejs npm yarn

# clean
RUN apk del .build-deps && rm -rf /var/cache/apk/*

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php -r "if (hash_file('sha384', 'composer-setup.php') === '756890a4488ce9024fc62c56153228907f1545c228516cbf63f885e036d37e9a59d27d63f46af1d4d07ee0f76181c7d3') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
    && php composer-setup.php \
    && php -r "unlink('composer-setup.php');" \
    && mv composer.phar /usr/local/bin/composer

ENV COMPOSER_HOME=/usr/local/.composer
RUN echo PHP Version: $VERSION && php -v
RUN if [[ "x$VERSION" == "x5.6" ]] ; then composer global require phpunit/phpunit 4.8.35 ; \
  elif [[ "x$VERSION" == "x7.2" ]] ; then composer global require phpunit/phpunit 6.5.5 ; \
  else composer global require --ignore-platform-req=php phpunit/phpunit 9.5.0; fi

RUN composer global require pmvc/pmvc-cli \
  && ln -s /usr/local/.composer/vendor/bin/pmvc /usr/local/bin/ \
  && ln -s /usr/local/.composer/vendor/bin/phpunit /usr/local/bin/

# fixed timezone
# https://stackoverflow.com/questions/45587214/configure-timezone-in-dockerized-nginx-php-fpm/45587945
RUN printf '[PHP]\ndate.timezone = "UTC"\n' > /usr/local/etc/php/conf.d/tzone.ini

WORKDIR /var/www/html
