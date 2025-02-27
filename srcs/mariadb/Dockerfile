FROM debian:bullseye

RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y mariadb-server mariadb-client

COPY ./mdb-conf.sh /mdb-conf.sh
RUN chmod +x /mdb-conf.sh

EXPOSE 3306

ENTRYPOINT ["/mdb-conf.sh"]