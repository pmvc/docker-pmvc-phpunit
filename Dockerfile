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
  COMPOSER_ALLOW_SUPERUSER=1 \
  LANG=en_US.UTF-8 \
  LANGUAGE=en_US:en \ 
LC_ALL=en_US.UTF-8 \
  PATH=$PATH:./node_modules/.bin:./vendor/bin

# apk
COPY ./docker/install-phpunit ./docker/install-packages /usr/local/bin/
RUN apk update && apk add bash bc \
  && INSTALL_VERSION=$VERSION install-packages \
  && rm /usr/local/bin/install-packages

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
  && php -r "if (hash_file('sha384', 'composer-setup.php') === file_get_contents('https://raw.githubusercontent.com/composer/composer.github.io/main/installer.sig')) { echo 'Installer verified'; } else { fwrite(STDERR, 'Verify composer signature failed.'); unlink('composer-setup.php'); } echo PHP_EOL;" \
  && php composer-setup.php \
  && php -r "unlink('composer-setup.php');" \
  && mv composer.phar /usr/local/bin/composer \
  && /usr/local/bin/composer --version

RUN chmod +x /usr/local/bin/install-phpunit \
  && install-phpunit \
  && composer global require pmvc/pmvc-cli:^85.0.0 squizlabs/php_codesniffer:^3.11 \
  && cd / && composer update \
  && chmod 0777 /.composer \
  && chmod 0777 -R /.composer/cache \
  && ln -s /.composer/vendor/bin/pmvc /usr/local/bin/ \
  && ln -s /.composer/vendor/bin/phpunit /usr/local/bin/ \
  && ln -s /.composer/vendor/bin/phpcs /usr/local/bin/ \
  && ln -s /.composer/vendor/bin/phpcbf /usr/local/bin/ \
  && rm /usr/local/bin/install-phpunit

# fixed timezone
# https://stackoverflow.com/questions/45587214/configure-timezone-in-dockerized-nginx-php-fpm/45587945
RUN printf '[PHP]\ndate.timezone = "UTC"\n' > /usr/local/etc/php/conf.d/tzone.ini

VOLUME ["/.composer"]
WORKDIR /var/www/html

COPY ./docker/entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["server"]
