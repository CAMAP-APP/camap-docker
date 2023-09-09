FROM node:20.3.1-bullseye-slim
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
#COPY camap-hx/apache.conf /etc/apache2/sites-available/camap.conf
#RUN a2ensite camap

RUN npm install -g lix

RUN chown www-data:www-data /srv /var/www

RUN haxelib setup /usr/share/haxelib
RUN haxelib install templo
RUN cd /usr/bin && haxelib run templo
# WHY: src/App.hx:20: characters 58-84 : Cannot execute `git log -1 --format=%h`. fatal: not a git repository (or any of the parent directories): .git
# TODO: remove
COPY --chown=www-data:www-data ./camap-hx/.git /srv/.git
COPY --chown=www-data:www-data ./camap-hx/common/ /srv/common/
COPY --chown=www-data:www-data ./camap-hx/data/ /srv/data/
COPY --chown=www-data:www-data ./camap-hx/js/ /srv/js/
COPY --chown=www-data:www-data ./camap-hx/lang/ /srv/lang/
COPY --chown=www-data:www-data ./camap-hx/src/ /srv/src/
COPY --chown=www-data:www-data ./camap-hx/www/ /srv/www/

USER www-data

WORKDIR /srv/www
RUN echo "User-agent: *" > robots.txt
RUN echo "Disallow: /" >> robots.txt
RUN echo "Allow: /group/" >> robots.txt

COPY --chown=www-data:www-data ./camap-hx/backend/ /srv/backend/
WORKDIR /srv/backend
RUN lix scope create
RUN lix install haxe 4.0.5
RUN lix use haxe 4.0.5
RUN lix download

COPY --chown=www-data:www-data ./camap-hx/frontend/ /srv/frontend/
WORKDIR /srv/frontend
RUN lix scope create
RUN lix use haxe 4.0.5
RUN lix download
RUN npm install

WORKDIR /srv
COPY ./camap-hx/config.xml /srv/config.xml

WORKDIR /srv/backend

RUN haxe build.hxml -D i18n_generation;
RUN mkdir ../lang/master/tmp
RUN chmod 777 ../lang/master/tmp
RUN chown www-data.www-data ../www/file

WORKDIR /srv/frontend
RUN haxe build.hxml

WORKDIR /srv/lang/fr/tpl/
RUN neko ../../../backend/temploc2.n -macros macros.mtt -output ../tmp/ *.mtt */*.mtt */*/*.mtt

WORKDIR /srv

# holds connexion config
COPY --chown=www-data:www-data ./camap-hx/scripts/ /srv/scripts/
COPY ./camap-hx/config.xml config-raw.xml
USER root
RUN echo "Europe/Paris" > /etc/timezone
CMD ["bash", "scripts/start.sh", "config-raw.xml", "config.xml" ]
