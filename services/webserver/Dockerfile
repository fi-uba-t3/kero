FROM romeoz/docker-nginx-php:7.2

RUN apt-get update && \
apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install wget php7.2-ldap

RUN mkdir -p /var/www/kero.wiki.io && \
cd /var/www/kero.wiki.io && wget https://download.dokuwiki.org/src/dokuwiki/dokuwiki-rc.tgz && \
tar xvf dokuwiki-rc.tgz && rm dokuwiki-rc.tgz && mv dokuwiki-*/* . && \
mv dokuwiki-*/.* . || true && rmdir dokuwiki-* && rm install.php
ADD wiki/conf/* /var/www/kero.wiki.io/conf/
RUN chown -R www-data:www-data /var/www/kero.wiki.io

RUN apt-get -y install unzip && mkdir -p /var/www/kero.ecommerce.io && \
cd /var/www/kero.ecommerce.io && \
wget https://getgrav.org/download/skeletons/shop-site/1.0.0 -O shop.zip && \
unzip shop.zip && rm shop.zip && mv grav-*/* . && mv grav-*/.* . || true && rmdir grav-*/ && \
bin/gpm install email && bin/gpm install login && bin/gpm install admin
ADD ecommerce/user/config/* /var/www/kero.ecommerce.io/user/config/
ADD ecommerce/system/config/* /var/www/kero.ecommerce.io/system/config/
RUN chown -R www-data:www-data /var/www/kero.ecommerce.io

ADD *.conf /etc/nginx/conf.d/
