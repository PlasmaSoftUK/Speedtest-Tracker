FROM arm32v7/debian:bullseye

LABEL maintainer="PlasmaSoft"

ARG WWWGROUP=1000
ARG MYSQL_CLIENT="default-mysql-client"
ARG SPEEDTEST_VERSION=1.2.0

WORKDIR /app/www

ENV COMPOSER_ALLOW_SUPERUSER=1
ENV WWWUSER=1337
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC
ENV SUPERVISOR_PHP_COMMAND="/usr/bin/php -d variables_order=EGPCS /app/www/artisan serve --host=0.0.0.0 --port=80"
ENV SUPERVISOR_PHP_USER="sail"

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone

RUN echo "Acquire::http::Pipeline-Depth 0;" > /etc/apt/apt.conf.d/99custom && \
    echo "Acquire::http::No-Cache true;" >> /etc/apt/apt.conf.d/99custom && \
    echo "Acquire::BrokenProxy true;" >> /etc/apt/apt.conf.d/99custom

RUN apt-get update && apt-get upgrade -y && \
    mkdir -p /etc/apt/keyrings && \
    apt-get install -y \
        gnupg gosu curl ca-certificates zip unzip git supervisor \
        sqlite3 libcap2-bin libpng-dev python3 \
        dnsutils iputils-ping librsvg2-bin fswatch \
        lsb-release apt-transport-https && \
    \
    curl -fsSL https://packages.sury.org/php/apt.gpg | gpg --dearmor -o /etc/apt/keyrings/sury.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/sury.gpg] https://packages.sury.org/php/ bullseye main" \
        > /etc/apt/sources.list.d/sury.list && \
    \
    curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor -o /etc/apt/keyrings/pgdg.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/pgdg.gpg] http://apt.postgresql.org/pub/repos/apt bullseye-pgdg main" \
        > /etc/apt/sources.list.d/pgdg.list && \
    \
    apt-get update && apt-get install -y \
        php8.4-cli php8.4-dev php8.4-pgsql php8.4-sqlite3 php8.4-gd php8.4-curl \
        php8.4-mysql php8.4-mbstring php8.4-xml php8.4-zip php8.4-bcmath \
        php8.4-soap php8.4-intl php8.4-readline php8.4-msgpack php8.4-igbinary \
        php8.4-redis && \
    \
    curl -sLS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer && \
    \
    apt-get install -y ${MYSQL_CLIENT} && \
    apt-get install -y postgresql-client && \
    \
    ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then \
        PLATFORM="x86_64"; \
    elif [ "$ARCH" = "aarch64" ]; then \
        PLATFORM="aarch64"; \
    elif [ "$ARCH" = "armv7l" ]; then \
        PLATFORM="armhf"; \
    else \
        echo "Unsupported architecture: $ARCH"; exit 1; \
    fi && \
    \
    curl -L -o /tmp/speedtest-cli.tgz \
        "https://install.speedtest.net/app/cli/ookla-speedtest-${SPEEDTEST_VERSION}-linux-${PLATFORM}.tgz" && \
    tar -xzf /tmp/speedtest-cli.tgz -C /usr/bin && \
    \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs

RUN setcap "cap_net_bind_service=+ep" /usr/bin/php8.4

RUN userdel -r ubuntu || true
RUN groupadd --force -g $WWWGROUP sail
RUN useradd -ms /bin/bash --no-user-group -g $WWWGROUP -u 1337 sail

RUN git config --global --add safe.directory /app/www

COPY docker/8.4/start-container /usr/local/bin/start-container
COPY docker/8.4/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY docker/8.4/php.ini /etc/php/8.4/cli/conf.d/99-sail.ini

COPY . /app/www

RUN composer install \
    --no-dev \
    --optimize-autoloader \
    --no-interaction

RUN chown -R sail:sail /app/www

RUN find /app/www -type d -exec chmod 755 {} \; && \
    find /app/www -type f -exec chmod 644 {} \;

RUN chmod +x /app/www/artisan || true
RUN chmod +x /usr/local/bin/start-container

RUN mkdir -p /config/storage /config/logs /config/cache

EXPOSE 80/tcp

ENTRYPOINT ["start-container"]