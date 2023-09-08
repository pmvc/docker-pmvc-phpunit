ARG VERSION=${VERSION:-[VERSION]}
ARG ALT_VERSION=${ALT_VERSION:-fpm-alpine}

FROM smizy/libsvm AS builder

FROM php:${VERSION}-${ALT_VERSION}

ARG VERSION

COPY --from=builder \
    /usr/local/bin/svm-train \
    /usr/local/bin/svm-predict \
    /usr/local/bin/svm-scale \
    /usr/local/bin/
COPY ./docker/cacert.pem /usr/local/share/ca-certificates/cacert.pem
COPY ./docker/composer.json /

ENV COMPOSER_HOME=/.composer \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \ 
    LC_ALL=en_US.UTF-8 \
    PATH=$PATH:./node_modules/.bin:./vendor/bin

# apk
COPY ./install-packages.sh /usr/local/bin/install-packages
RUN apk update && apk add bash bc \
  && INSTALL_VERSION=$VERSION install-packages \
  && rm /usr/local/bin/install-packages;

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php -r "if (hash_file('sha384', 'composer-setup.php') === file_get_contents('https://raw.githubusercontent.com/composer/composer.github.io/main/installer.sig')) { echo 'Installer verified'; } else { fwrite(STDERR, 'Verify composer signature failed.'); unlink('composer-setup.php'); } echo PHP_EOL;" \
    && php composer-setup.php \
    && php -r "unlink('composer-setup.php');" \
    && mv composer.phar /usr/local/bin/composer

RUN if [[ $(echo "$VERSION <= 7.1" | bc -l) == 1 ]] ; then composer global require phpunit/phpunit 4.8.36 ; \
  elif [[ $(echo "$VERSION <= 7.4" | bc -l) == 1 ]] ; then composer global require phpunit/phpunit 6.5.14 ; \
  elif [[ $(echo "$VERSION <= 8.0" | bc -l) == 1 ]] ; then composer global require phpunit/phpunit 9.6.3 ; \
  else composer global require \
    phpunit/phpunit 10.0.11 \
    php-coveralls/php-coveralls \
    && ln -s /.composer/vendor/bin/php-coveralls /usr/local/bin/coveralls \
  ; fi \
  && composer global require pmvc/pmvc-cli:^0.6.2 \
  && cd / && composer update \
  && chmod 0777 /.composer \
  && chmod 0777 -R /.composer/cache \
  && ln -s /.composer/vendor/bin/pmvc /usr/local/bin/ \
  && ln -s /.composer/vendor/bin/phpunit /usr/local/bin/

# fixed timezone
# https://stackoverflow.com/questions/45587214/configure-timezone-in-dockerized-nginx-php-fpm/45587945
RUN printf '[PHP]\ndate.timezone = "UTC"\n' > /usr/local/etc/php/conf.d/tzone.ini

VOLUME ["/.composer"]
WORKDIR /var/www/html

COPY ./docker/entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["server"]
