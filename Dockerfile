FROM ubuntu:18.04

MAINTAINER Nguyen Ngoc Vinh <ngocvinh.nnv@gmail.com>

RUN DEBIAN_FRONTEND=noninteractive

ENV TERM xterm

RUN apt update && apt install -y \
        software-properties-common \
        locales \
        tzdata \
        libxml2-dev \
        apt-utils

RUN locale-gen en_US.UTF-8

ENV LANGUAGE=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV LC_CTYPE=UTF-8
ENV LANG=en_US.UTF-8

RUN echo "Asia/Ho_Chi_Minh" > /etc/timezone \
    && rm /etc/timezone \
    && dpkg-reconfigure -f noninteractive tzdata

# Install PHP and extensions
RUN add-apt-repository -y ppa:ondrej/php
RUN apt-get update && apt-get install -y --force-yes \
        php7.2-cli \
        php7.2-common \
        php7.2-curl \
        php7.2-json \
        php7.2-xml \
        php7.2-mbstring \
        php7.2-mysql \
        php7.2-pgsql \
        php7.2-sqlite \
        php7.2-sqlite3 \
        php7.2-zip \
        php7.2-gd \
        php7.2-fpm \
        php-xdebug \
        php7.2-bcmath \
        php7.2-intl \
        php7.2-soap \
        php7.2-dev \
        php-memcached \
        libcurl4-openssl-dev \
        libedit-dev \
        libssl-dev \
        libxml2-dev \
        xz-utils \
        sqlite3 \
        libsqlite3-dev \
        git \
        curl \
        vim \
        nano \
        net-tools \
        pkg-config \
        iputils-ping \
        libmcrypt-dev \
        libreadline-dev

# Install MongoDB PHP extension
RUN pecl channel-update pecl.php.net \
    && pecl install mongodb \
    && echo "extension=mongodb.so" >> `php --ini | grep "Loaded Configuration" | sed -e "s|.*:\s*||"`

# Install MCRYPT PHP extension
RUN pecl channel-update pecl.php.net \
    && pecl install mcrypt-1.0.1 \
    && echo "extension=mcrypt.so" >> `php --ini | grep "Loaded Configuration" | sed -e "s|.*:\s*||"`

# Add composer binaries to path
RUN echo "export PATH=${PATH}:/var/www/laravel/vendor/bin:/root/.composer/vendor/bin" >> ~/.bashrc

# Load xdebug Zend extension with phpunit command
RUN sed -i 's/^/;/g' /etc/php/7.2/cli/conf.d/20-xdebug.ini
RUN echo "alias phpunit='php -dzend_extension=xdebug.so /var/www/laravel/vendor/bin/phpunit'" >> ~/.bashrc

# Install Nodejs
RUN curl -sL https://deb.nodesource.com/setup_9.x | bash - \
    && apt-get install -y nodejs

# Install Yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
    && apt update \
    && apt install yarn

# Install Composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php -r "if (hash_file('SHA384', 'composer-setup.php') === '544e09ee996cdf60ece3804abc52599c22b1f40f4323403c44d44fdfdd586475ca9813a858088ffbc1f233e9b180f061') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
    && php composer-setup.php \
    && php -r "unlink('composer-setup.php');" \
    && mv composer.phar /usr/bin/composer

# Clean up
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /var/www/app
