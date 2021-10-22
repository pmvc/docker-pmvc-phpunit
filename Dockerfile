ARG VERSION=${VERSION:-[VERSION]}

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

RUN apk update && apk add bash

# tensor
RUN echo $VERSION && apk add --virtual .build-deps musl-dev bc \
  && if [[ $(echo "$VERSION >= 7.4" | bc -l) == 1 ]] ; then \
  apk add --virtual .build-deps \ 
  lapack-dev \
  libexecinfo-dev \
  openblas-dev \
  ; fi

RUN docker-php-ext-install \
  pcntl \
  sockets

# svm library
RUN apk add \ 
  libgomp \
  libstdc++ \
  libgcc

# nodejs
RUN if [[ $(echo "$VERSION == 7.0" | bc -l) == 1 ]] ; then apk add nodejs yarn; \
  elif [[ $(echo "$VERSION == 5.5" | bc -l) == 1 ]] ; then apk add nodejs; \
  else apk add nodejs npm yarn; fi

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php -r "if (hash_file('sha384', 'composer-setup.php') === '906a84df04cea2aa72f40b5f787e49f22d4c2f19492ac310e8cba5b96ac8b64115ac402c8cd292b8a03482574915d1a8') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
    && php composer-setup.php \
    && php -r "unlink('composer-setup.php');" \
    && mv composer.phar /usr/local/bin/composer

ENV COMPOSER_HOME=/.composer \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \ 
    LC_ALL=en_US.UTF-8

RUN echo Build Version: $VERSION && php -v
RUN if [[ $(echo "$VERSION <= 7.1" | bc -l) == 1 ]] ; then composer global require phpunit/phpunit 4.8.35 ; \
  elif [[ $(echo "$VERSION <= 7.4" | bc -l) == 1 ]] ; then composer global require phpunit/phpunit 6.5.5 ; \
  else composer global require --ignore-platform-req=php phpunit/phpunit 9.5.0; fi

# clean
RUN apk del .build-deps && rm -rf /var/cache/apk/*

RUN composer global require pmvc/pmvc-cli:^0.4.1 \
  && chmod 0777 /.composer \
  && chmod 0777 -R /.composer/cache \
  && ln -s /.composer/vendor/bin/pmvc /usr/local/bin/ \
  && ln -s /.composer/vendor/bin/phpunit /usr/local/bin/

# fixed timezone
# https://stackoverflow.com/questions/45587214/configure-timezone-in-dockerized-nginx-php-fpm/45587945
RUN printf '[PHP]\ndate.timezone = "UTC"\n' > /usr/local/etc/php/conf.d/tzone.ini

VOLUME ["/.composer"]
WORKDIR /var/www/html
