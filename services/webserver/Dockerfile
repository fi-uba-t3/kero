FROM romeoz/docker-nginx-php:7.2

RUN apt-get update && \
apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install wget php7.2-ldap

RUN mkdir /wiki && cd /wiki && \
wget https://download.dokuwiki.org/src/dokuwiki/dokuwiki-stable.tgz && \
tar xvf dokuwiki-stable.tgz && rm dokuwiki-stable.tgz && mv dokuwiki-*/* . && \
mv dokuwiki-*/.* . || true && rmdir dokuwiki-* && rm install.php
ADD wiki/conf/* /wiki/conf/

RUN apt-get -y install unzip && mkdir /ecommerce && cd /ecommerce && \
wget https://getgrav.org/download/skeletons/shop-site/1.0.0 -O shop.zip && \
unzip shop.zip && rm shop.zip && mv grav-*/* . && mv grav-*/.* . || true && rmdir grav-*/ && \
bin/gpm install email && bin/gpm install login && bin/gpm install admin
ADD ecommerce/user/config/* /ecommerce/user/config/
ADD ecommerce/user/plugins/snipcart/* /ecommerce/user/plugins/snipcart/
ADD ecommerce/system/config/* /ecommerce/system/config/
