FROM php:7.3-fpm-alpine

RUN apk add --update \
     curl \
     libzip-dev \
     mysql-client \
     unzip \
     zip

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN composer --version
RUN composer global require hirak/prestissimo

RUN docker-php-ext-install pdo pdo_mysql

ARG ENABLE_NEW_RELIC="false"
ARG NEW_RELIC_APP_KEY=""
ARG NEW_RELIC_APP_NAME="App"
RUN set -ex; \
    if [ "${ENABLE_NEW_RELIC}" == "true" ]; then \
        echo "[Tiny API] Installing New-Relic agent..."; \
        curl -L https://download.newrelic.com/php_agent/release/newrelic-php5-8.7.0.242-linux-musl.tar.gz | tar -C /tmp -zx && \
        export NR_INSTALL_USE_CP_NOT_LN=1 && \
        export NR_INSTALL_SILENT=1 && \
        /tmp/newrelic-php5-*/newrelic-install install && \
        rm -rf /tmp/newrelic-php5-* /tmp/nrinstall* && \
        sed -i -e "s/\"REPLACE_WITH_REAL_KEY\"/\"${NEW_RELIC_APP_KEY}\"/" \
        -e "s/newrelic.appname = \"PHP Application\"/newrelic.appname = \"${NEW_RELIC_APP_NAME}\"/" \
        /usr/local/etc/php/conf.d/newrelic.ini; \
    else \
        echo "[Tiny API] Running without New-Relic agent"; \
    fi;

# Xdebug (if applicable)
ARG XDEBUG_VERSION=2.7.0
ARG ENABLE_XDEBUG="false"
RUN set -ex; \
    if [ "${ENABLE_XDEBUG}" == "true" ]; then  \
    echo "[Tiny API] Installing xdebug..."; \
    apk --no-cache add pcre-dev ${PHPIZE_DEPS} && \
        pecl install xdebug && \
        docker-php-ext-enable xdebug && \
        apk del pcre-dev ${PHPIZE_DEPS}; \
  fi;

WORKDIR /var/www

