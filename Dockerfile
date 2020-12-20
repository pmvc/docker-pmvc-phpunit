ARG VERSION=${VERSION:-5.6.40}

FROM php:${VERSION}-fpm-alpine

ARG VERSION=${VERSION:-5.6.40}

RUN apk update && apk add bash && rm -rf /var/cache/apk/*

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php -r "if (hash_file('sha384', 'composer-setup.php') === '756890a4488ce9024fc62c56153228907f1545c228516cbf63f885e036d37e9a59d27d63f46af1d4d07ee0f76181c7d3') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
    php composer-setup.php && \
    php -r "unlink('composer-setup.php');"

RUN mv composer.phar /usr/local/bin/composer
RUN echo PHP Version: $VERSION && php -v
RUN if [[ "x$VERSION" != "x8.0.0" ]] ; then composer global require phpunit/phpunit 4.8.35 ; \ 
  else composer global require --ignore-platform-req=php phpunit/phpunit 9.5.0; fi
RUN composer global require pmvc/pmvc-cli
ENV PATH="/root/.composer/vendor/bin:${PATH}"

