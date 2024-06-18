FROM mysql:8.0.36-debian

LABEL org.opencontainers.image.authors="InterAMAP44 inter@amap44.org"
LABEL org.opencontainers.image.vendor="InterAMAP 44"
LABEL org.opencontainers.image.source="https://github.com/Mandrak-Kimigo/camap-docker"
LABEL org.opencontainers.image.licenses="GPL-3.0-or-later"
LABEL description="Camap mysql container"
LABEL org.opencontainers.image.title="mysql"
LABEL org.opencontainers.image.description="Container 3/3 de l'application Camap (mysql)"

COPY ./camap-ts/mysql/my.cnf /etc/mysql/conf.d/
ENV TZ="Europe/Paris" 
RUN echo "Europe/Paris" > /etc/timezone
