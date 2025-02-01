[![CircleCI](https://circleci.com/gh/pmvc/docker-pmvc-phpunit/tree/main.svg?style=svg)](https://circleci.com/gh/pmvc/docker-pmvc-phpunit/tree/main)
[![Docker Pulls](https://img.shields.io/docker/pulls/allfunc/pmvc-phpunit.svg)](https://hub.docker.com/r/allfunc/pmvc-phpunit)

# PMVC PHPUNIT Docker Image

-   The latest locked version is `PHP 8.4`.

## phpunit version

There are thee major phpunit version.

-   PHP 5.6 [7.0, 7.1] use phpunit 4.8.36
-   PHP 7.2 [7.3, 7.4] use phpunit 6.5.14
-   php 8.0 use phpunit 9.6.11
-   php 8.1 [8.2, 8.3, 8.4] use phpunit 10.3.3
-   phpunit support version
    -   https://phpunit.de/supported-versions.html

## Features

-   support utc timezone without date_default_timezone_set
-   support phpunit [4.8.36 - 9.5.10]
-   support xdebug for code coverage [3.1.1]
    -   support php-coveralls and https://coveralls.io/
-   support pmvc command line
-   support pdo-[mysql, pgsql, sqlite]

### Advance feature

-   GD only in [php 5.6 and 8.0 later]
-   NodeJS command for your frontend project.
-   Machine Learning (Need php7.4 later)
    -   SVM Library
        -   https://php-ml.readthedocs.io/en/latest/machine-learning/regression/least-squares/
    -   RubixML
        -   https://docs.rubixml.com/1.0/index.html
    -   RubixML tensor (Only in php 8.2 and alpine3.16)
        -   https://github.com/mlocati/docker-php-extension-installer#special-requirements-for-tensor

## GIT

-   https://github.com/pmvc/docker-pmvc-phpunit

## Docker hub

-   Image Name: allfunc/pmvc-phpunit
-   https://hub.docker.com/r/allfunc/pmvc-phpunit

### Check entrypoint

```
docker run --rm allfunc/pmvc-phpunit cat /usr/local/bin/docker-php-entrypoint
```

## Troubleshooting

https://github.com/pmvc/docker-pmvc-phpunit/blob/main/bin/README.md

## Use with CircleCI

Build your ci within 3 run command.

-   [CircleCI configure file example](https://github.com/pmvc/generator-php-pmvc-plugin/blob/master/generators/app/templates/_circleci/config.yml)
-   [Real CircleCI demo](https://app.circleci.com/pipelines/github/pmvc/pmvc)

MIT 2025
