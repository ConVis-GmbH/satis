#!/bin/bash

cd /home/www/p563318/html/satis.con-vis.de || exit
COMPOSER_CACHE_DIR=/home/www/p563318/html/.composer bin/satis build
exit 0
