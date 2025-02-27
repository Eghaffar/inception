FROM debian:bullseye

RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y nginx openssl ca-certificates

RUN mkdir -p /etc/nginx/ssl
#generation certificat : utilisation dopenssl, creation certificat autosigne, specification des details du certificat
RUN openssl req -x509 -nodes -out /etc/nginx/ssl/inception.crt -keyout /etc/nginx/ssl/inception.key -subj "/C=FR/ST=KH/L=KH/O=42/OU=42/CN=eghaffar.42.fr/UID=eghaffar"

RUN mkdir -p /usr/local/share/ca-certificates && \
    cp /etc/nginx/ssl/inception.crt /usr/local/share/ca-certificates/inception.crt && \
    chmod 644 /usr/local/share/ca-certificates/inception.crt && \
    update-ca-certificates --fresh && \
    cp /etc/ssl/certs/ca-certificates.crt /etc/nginx/ssl/ca-certificates.crt

COPY ./nginx.conf /etc/nginx/nginx.conf

RUN mkdir -p /var/www/wordpress
RUN chown -R www-data:www-data /var/www/wordpress

CMD ["nginx", "-g", "daemon off;"]