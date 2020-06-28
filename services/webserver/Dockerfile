FROM romeoz/docker-nginx-php:7.0

RUN apt-get update && apt-get -y install wget && mkdir -p /var/www/kero.wiki.io && \
cd /var/www/kero.wiki.io && wget https://download.dokuwiki.org/src/dokuwiki/dokuwiki-rc.tgz && \
tar xvf dokuwiki-rc.tgz && rm dokuwiki-rc.tgz && mv dokuwiki-*/* . && \
mv dokuwiki-*/.* .; exit 0 && rmdir dokuwiki-*/
RUN chown -R www-data:www-data /var/www/kero.wiki.io

ADD kero.ecommerce.io /var/www/kero.ecommerce.io
ADD *.conf /etc/nginx/conf.d/
