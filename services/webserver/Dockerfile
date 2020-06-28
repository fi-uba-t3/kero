FROM romeoz/docker-nginx-php:7.2

RUN apt-get update && apt-get -y install wget && mkdir -p /var/www/kero.wiki.io && \
cd /var/www/kero.wiki.io && wget https://download.dokuwiki.org/src/dokuwiki/dokuwiki-rc.tgz && \
tar xvf dokuwiki-rc.tgz && rm dokuwiki-rc.tgz && mv dokuwiki-*/* . && \
mv dokuwiki-*/.* .; exit 0 && rmdir dokuwiki-*/
RUN chown -R www-data:www-data /var/www/kero.wiki.io

RUN apt-get -y install unzip && mkdir -p /var/www/kero.ecommerce.io && \
cd /var/www/kero.ecommerce.io && \
wget https://getgrav.org/download/skeletons/shop-site/1.0.0 -O shop.zip && \
unzip shop.zip && rm shop.zip && mv grav-*/* . && mv grav-*/.* .; exit 0 && rmdir grav-*/
RUN chown -R www-data:www-data /var/www/kero.ecommerce.io

ADD *.conf /etc/nginx/conf.d/
