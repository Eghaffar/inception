FROM debian:bullseye

RUN apt-get update && apt-get upgrade -y

RUN apt-get install -y \
    curl \
    php7.4-fpm \
    php7.4-mysql \
    php7.4-curl \
    php7.4-gd \
    php7.4-mbstring \
    php7.4-xml \
    php7.4-zip \
    php7.4-intl \
    mariadb-client

COPY ./wp_conf.sh /
RUN chmod +x /wp_conf.sh

EXPOSE 9000

ENTRYPOINT ["/wp_conf.sh"]