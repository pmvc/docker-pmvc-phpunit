ARG VERSION=${VERSION:-7.2}

FROM php:${VERSION}-fpm-alpine

ARG VERSION

RUN apk update && apk add bash \
  && docker-php-ext-install pcntl \
  && rm -rf /var/cache/apk/*

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php -r "if (hash_file('sha384', 'composer-setup.php') === '756890a4488ce9024fc62c56153228907f1545c228516cbf63f885e036d37e9a59d27d63f46af1d4d07ee0f76181c7d3') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
    php composer-setup.php && \
    php -r "unlink('composer-setup.php');"

RUN mv composer.phar /usr/local/bin/composer
RUN echo PHP Version: $VERSION && php -v
RUN if [[ "x$VERSION" == "x5.6" ]] ; then composer global require phpunit/phpunit 4.8.35 ; \
  elif [[ "x$VERSION" == "x7.2" ]] ; then composer global require phpunit/phpunit 6.5.5 ; \
  else composer global require --ignore-platform-req=php phpunit/phpunit 9.5.0; fi

ENV PATH="/root/.composer/vendor/bin:${PATH}"
RUN composer global require pmvc/pmvc-cli

# fixed timezone
# https://stackoverflow.com/questions/45587214/configure-timezone-in-dockerized-nginx-php-fpm/45587945
RUN printf '[PHP]\ndate.timezone = "UTC"\n' > /usr/local/etc/php/conf.d/tzone.ini

WORKDIR /var/www/html
