## Simple command

### PHP
```
curl https://gist.githubusercontent.com/HillLiu/fa84bc3327cdccc248c5484f4df05755/raw/a8c6ae3e5ed9473d04432423182c79f7e36ebf4c/demo-7x8x-mixed.php | docker run --rm -i allfunc/pmvc-phpunit:8.1 php

curl https://gist.githubusercontent.com/HillLiu/fa84bc3327cdccc248c5484f4df05755/raw/a8c6ae3e5ed9473d04432423182c79f7e36ebf4c/demo-7x8x-mixed.php | docker run --rm -i allfunc/pmvc-phpunit:7.4 php
```

### Composer
```
docker run --rm -i allfunc/pmvc-phpunit:7.4 composer
```
