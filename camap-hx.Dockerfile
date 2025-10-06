FROM node:20.18.3

LABEL org.opencontainers.image.authors="InterAMAP44 inter@amap44.org"
LABEL org.opencontainers.image.vendor="InterAMAP 44"
LABEL org.opencontainers.image.source="https://github.com/CAMAP-APP/camap-docker"
LABEL org.opencontainers.image.licenses="GPL-3.0-or-later"
LABEL description="Camap neko-loc-camap container"
LABEL org.opencontainers.image.title="neko-loc-camap"
LABEL org.opencontainers.image.description="Container 1/3 de l'application Camap (camap-hx)"

RUN apt-get update && \
    apt-get install -y git curl imagemagick apache2 haxe libapache2-mod-neko libxml-twig-perl libutf8-all-perl procps && \
    apt-get clean

ENV TZ="Europe/Paris"
ENV APACHE_RUN_USER=www-data
ENV APACHE_RUN_GROUP=www-data
ENV APACHE_LOG_DIR=/var/log/apache2
# This value should be overridden by CI/CD
ENV VERSION=unknown
# redirect all logs to stdtout
RUN ln -sf /proc/self/fd/1 /var/log/apache2/access.log && \
    ln -sf /proc/self/fd/1 /var/log/apache2/error.log
RUN a2enmod rewrite
RUN a2enmod neko

RUN sed -i 's/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf
RUN sed -i 's!/var/www!/srv/www!' /etc/apache2/apache2.conf
RUN sed -i 's!Options Indexes FollowSymLinks!Options FollowSymLinks!' /etc/apache2/apache2.conf
RUN sed -i 's!/var/www/html!/srv/www!g' /etc/apache2/sites-available/000-default.conf

# lib and version management for haxe
RUN npm install -g lix

RUN chown www-data:www-data /srv /var/www

RUN haxelib setup /usr/share/haxelib
RUN haxelib install templo
RUN cd /usr/bin && haxelib run templo

COPY --chown=www-data:www-data ./camap-hx/common/ /srv/common/
COPY --chown=www-data:www-data ./camap-hx/data/ /srv/data/
COPY --chown=www-data:www-data ./camap-hx/js/ /srv/js/
COPY --chown=www-data:www-data ./camap-hx/lang/ /srv/lang/
COPY --chown=www-data:www-data ./camap-hx/src/ /srv/src/
COPY --chown=www-data:www-data ./camap-hx/www/ /srv/www/
COPY --chown=www-data:www-data ./camap-hx/backend/ /srv/backend/
COPY --chown=www-data:www-data ./camap-hx/frontend/ /srv/frontend/

# copy config reference
COPY --chown=www-data:www-data ./camap-hx/config.xml /srv/config.xml

USER www-data

WORKDIR /srv/www
RUN echo "User-agent: *" > robots.txt
RUN echo "Disallow: /" >> robots.txt
RUN echo "Allow: /group/" >> robots.txt

WORKDIR /srv/backend
RUN lix scope create
RUN lix install haxe 4.0.5
RUN lix use haxe 4.0.5
RUN lix download

WORKDIR /srv/frontend
RUN lix scope create
RUN lix use haxe 4.0.5
RUN lix download
RUN npm install

WORKDIR /srv/backend

RUN haxe build.hxml -D i18n_generation;
RUN mkdir -p ../lang/master/tmp
RUN chmod 777 ../lang/master/tmp
RUN chown www-data.www-data ../www/file

WORKDIR /srv/frontend
RUN haxe build.hxml

WORKDIR /srv/lang/fr/tpl/
RUN neko ../../../backend/temploc2.n -macros macros.mtt -output ../tmp/ *.mtt */*.mtt */*/*.mtt

WORKDIR /srv

# holds connexion config
USER root
RUN echo "Europe/Paris" > /etc/timezone
ENTRYPOINT ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
