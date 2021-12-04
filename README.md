PMVC PHPUNIT Docker Image
======

[![CircleCI](https://circleci.com/gh/pmvc/docker-pmvc-phpunit/tree/main.svg?style=svg)](https://circleci.com/gh/pmvc/docker-pmvc-phpunit/tree/main)

## phpunit version

There are thee major phpunit version.
* PHP 5.6 [5.5, 7.0, 7.1] use phpunit 4.8.36
* PHP 7.2 [7.3, 7.4] use phpunit 6.5.14
* php 8.0 [8.1] use phpunit 9.5.10

## Features
* support utc timezone without date_default_timezone_set
* support phpunit [4.8.36 - 9.5.10]
* support xdebug for code coverage [3.1.1]
   * support php-coveralls and https://coveralls.io/
* support pmvc command line
* support pdo-[mysql, pgsql, sqlite]

### Advance feature
* NodeJS command for your frontend project.
* Machine Learning (Need php7.4 or above)
   * SVM Library 
      * https://php-ml.readthedocs.io/en/latest/machine-learning/regression/least-squares/
   * Rubiml
      * https://docs.rubixml.com/1.0/index.html

## GIT
   * https://github.com/pmvc/docker-pmvc-phpunit

## Docker hub
   * Image Name: hillliu/pmvc-phpunit
   * https://hub.docker.com/r/hillliu/pmvc-phpunit

## Use with CircleCI
Build your ci within 3 run command.
   * [CircleCI configure file example](https://github.com/pmvc/generator-php-pmvc-plugin/blob/master/generators/app/templates/_circleci/config.yml)
   * [Real CircleCI demo](https://app.circleci.com/pipelines/github/pmvc/pmvc)

MIT 2021
