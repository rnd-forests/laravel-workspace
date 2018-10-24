FROM php:7.2-cli

LABEL maintainer="Nguyen Ngoc Vinh <ngocvinh.nnv@gmail.com>"

ENV TERM xterm

ARG DEBIAN_FRONTEND=noninteractive
ARG DEBCONF_NONINTERACTIVE_SEEN=true

RUN apt-get update && apt-get install -y \
    software-properties-common \
    libpq-dev \
    libmemcached-dev \
    libmemcachedutil2 \
    libjpeg-dev \
    libpng-dev \
    libfreetype6-dev \
    libssl-dev \
    libxml2-dev \
    libmcrypt-dev \
    libbz2-dev \
    libsasl2-dev \
    zlib1g-dev \
    libicu-dev \
    libreadline-dev \
    libcurl4-openssl-dev \
    libedit-dev \
    libldap2-dev \
    iputils-ping \
    apt-utils \
    xz-utils \
    pkg-config \
    net-tools \
    tzdata \
    gnupg2 \
    htop \
    curl \
    nano \
    git \
    vim \
    zip \
    unzip \
    g++ \
    apt-transport-https \
    --no-install-recommends \
    && rm -r /var/lib/apt/lists/*

RUN echo "Asia/Ho_Chi_Minh" > /etc/timezone \
    && rm /etc/timezone \
    && dpkg-reconfigure -f noninteractive tzdata

RUN docker-php-ext-configure gd \
    --enable-gd-native-ttf \
    --with-jpeg-dir=/usr/lib \
    --with-freetype-dir=/usr/include/freetype2

RUN docker-php-ext-configure ldap \
    --with-libdir=lib/x86_64-linux-gnu/

RUN docker-php-ext-configure intl

RUN pecl channel-update pecl.php.net \
    && pecl install mongodb \
    && docker-php-ext-enable mongodb \
    && pecl install mcrypt-1.0.1 \
    && docker-php-ext-enable mcrypt \
    && pecl install memcached redis \
    && docker-php-ext-enable memcached redis

RUN docker-php-ext-install \
    bcmath \
    bz2 \
    calendar \
    iconv \
    mbstring \
    mysqli \
    pdo_mysql \
    pdo_pgsql \
    pgsql \
    opcache \
    gd \
    intl \
    soap \
    ldap \
    exif \
    zip \
    pcntl

RUN rm /bin/sh && ln -s /bin/bash /bin/sh

RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash

ARG NODE_VERSION=9.11.2
RUN source  ~/.nvm/nvm.sh \
    && nvm install lts/argon \
    && nvm install lts/boron \
    && nvm install lts/carbon \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default

ENV NODE_PATH /root/.nvm/versions/node/v$NODE_VERSION/lib/node_modules
ENV PATH /root/.nvm/versions/node/v$NODE_VERSION/bin:$PATH

RUN npm install gulp-cli -g
RUN ln -s /root/.nvm/versions/node/v$NODE_VERSION/bin/gulp /usr/bin/gulp

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
    && apt-get update \
    && apt-get install --no-install-recommends yarn

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php -r "if (hash_file('SHA384', 'composer-setup.php') === '93b54496392c062774670ac18b134c3b3a95e5a5e5c8f1a9f115f203b75bf9a129d5daa8ba6a13e2cc8a1da0806388a8') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
    && php composer-setup.php \
    && php -r "unlink('composer-setup.php');" \
    && mv composer.phar /usr/bin/composer \
    && echo "export PATH=${PATH}:/var/www/app/vendor/bin:/root/.composer/vendor/bin" >> ~/.bashrc

RUN composer global require \
    'squizlabs/php_codesniffer' \
    'phpmetrics/phpmetrics' \
    'pdepend/pdepend' \
    'phpmd/phpmd' \
    'sebastian/phpcpd' \
    && cd ~/.composer/vendor/squizlabs/php_codesniffer/src/Standards \
    && git clone https://github.com/wataridori/framgia-php-codesniffer.git Framgia

RUN ln -s /root/.composer/vendor/bin/phpcs /usr/bin/phpcs \
    && ln -s /root/.composer/vendor/bin/pdepend /usr/bin/pdepend \
    && ln -s /root/.composer/vendor/bin/phpmetrics /usr/bin/phpmetrics \
    && ln -s /root/.composer/vendor/bin/phpmd /usr/bin/phpmd \
    && ln -s /root/.composer/vendor/bin/phpcpd /usr/bin/phpcpd

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /var/www/app
