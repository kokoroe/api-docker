FROM ubuntu:14.04
MAINTAINER Axel Etcheverry <axel@etcheverry.biz>

RUN apt-get update -q && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --force-yes software-properties-common && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN add-apt-repository ppa:ondrej/php5-5.6 -y
RUN add-apt-repository ppa:maxmind/ppa -y
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C
RUN add-apt-repository ppa:nginx/development -y

RUN apt-get update -q && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --force-yes \
    libodbc1 unixodbc libmysqlclient18 libpq5 wget git re2c build-essential \
    tcl8.5 libcurl4-gnutls-dev zlib1g-dev libevent-dev libmagic-dev curl && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN wget http://sphinxsearch.com/files/sphinxsearch_2.2.8-release-0ubuntu12~trusty_amd64.deb && \
    dpkg -i sphinxsearch_2.2.8-release-0ubuntu12~trusty_amd64.deb && \
    rm sphinxsearch_2.2.8-release-0ubuntu12~trusty_amd64.deb

# Install MySQL 5.6
RUN apt-get update -q && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --force-yes \
    mysql-server && \
    service mysql stop && \
    sed -e 's/^datadir\t.*$/datadir = \/data/' -i /etc/mysql/my.cnf && \
    sed -e 's/^bind-address\t.*$/bind-address = 0.0.0.0/' -i /etc/mysql/my.cnf && \
    cp /etc/mysql/my.cnf /usr/share/mysql/my-default.cnf && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


RUN apt-get update -q && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --force-yes \
    geoipupdate && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN apt-get update -q && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --force-yes \
    dh-php5 php-pear php5-apcu php5-cli php5-common php5-curl php5-dev php5-gd php5-geoip \
    php5-imagick php5-intl php5-json php5-mcrypt php5-mysqlnd php5-readline php5-xdebug \
    pkg-php-tools php5-fpm && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN git clone https://github.com/silexphp/Pimple && \
    cd Pimple/ext/pimple && \
    phpize && \
    ./configure && \
    make && \
    make install && \
    cd ../../../ && \
    rm -rf Pimple

RUN wget http://download.redis.io/releases/redis-3.0.2.tar.gz && \
    tar xzf redis-3.0.2.tar.gz && \
    rm redis-3.0.2.tar.gz && \
    cd redis-3.0.2/ && \
    make && \
    make install && \
    cd utils && \
    ./install_server.sh && \
    cd ../../ && \
    rm -rf redis-3.0.2/

RUN git clone https://github.com/euskadi31/phpredis.git && \
    cd phpredis/ && \
    phpize && \
    ./configure && \
    make && \
    make install && \
    echo "; configuration for php Redis module" >> /etc/php5/mods-available/redis.ini && \
    echo "; priority=20" >> /etc/php5/mods-available/redis.ini && \
    echo "extension=redis.so" >> /etc/php5/mods-available/redis.ini && \
    php5enmod redis && \
    cd ../ && \
    rm -rf phpredis

RUN pecl install propro && \
    echo "; configuration for php propro module" >> /etc/php5/mods-available/propro.ini && \
    echo "; priority=10" >> /etc/php5/mods-available/propro.ini && \
    echo "extension=propro.so" >> /etc/php5/mods-available/propro.ini && \
    php5enmod propro

RUN pecl install raphf && \
    echo "; configuration for php raphf module" >> /etc/php5/mods-available/raphf.ini && \
    echo "; priority=10" >> /etc/php5/mods-available/raphf.ini && \
    echo "extension=raphf.so" >> /etc/php5/mods-available/raphf.ini && \
    php5enmod raphf

RUN pecl install pecl_http && \
    echo "; configuration for php http module" >> /etc/php5/mods-available/http.ini && \
    echo "; priority=30" >> /etc/php5/mods-available/http.ini && \
    echo "extension=http.so" >> /etc/php5/mods-available/http.ini && \
    php5enmod http

ADD scripts /scripts

RUN chmod +x /scripts/*.sh
RUN touch /.firstrun

