FROM node:20.12.1-bullseye-slim as builder

RUN apt-get update && apt-get install -y \
    g++ \
    libconfig-tiny-perl \
    libtest-script-perl \
    make \
    python3

RUN adduser --disabled-password --disabled-login --gecos "InterAMAP user" --home /home/interamap interamap
WORKDIR /srv
RUN chown interamap:interamap /srv

COPY --chown=interamap:interamap camap-ts/orm*.js camap-ts/package.json camap-ts/package-lock.json /srv/
COPY --chown=interamap:interamap camap-ts/packages/ /srv/packages
COPY --chown=interamap:interamap camap-ts/public/ /srv/public

USER interamap
# fetch retries to avoid network errors (timeout due to network latency)
RUN npm install --fetch-retries 4 install && npm cache clean --force
RUN npm rebuild node-sass --prefix packages/api-core

# doesn't work on the staging/prod server, replaced by 2 lines below
#RUN npm rebuild bcrypt --prefix packages/api-core
WORKDIR /srv/packages/api-core/node_modules/bcrypt 
RUN node-pre-gyp install --fallback-to-build

WORKDIR /srv
RUN npm rebuild sharp --prefix packages/api-core
RUN npm run build
## remove packages of devDependencies
RUN npm prune --production

COPY --chown=interamap:interamap ./camap-ts/scripts/ /srv/scripts

FROM  node:20.12.1-bullseye-slim

LABEL org.opencontainers.image.authors="InterAMAP44 inter@amap44.org"
LABEL org.opencontainers.image.vendor="InterAMAP 44"
LABEL org.opencontainers.image.source="https://github.com/CAMAP-APP/camap-docker"
LABEL org.opencontainers.image.licenses="GPL-3.0-or-later"
LABEL description="Camap nest-loc-camap container"
LABEL org.opencontainers.image.title="nest-loc-camap"
LABEL org.opencontainers.image.description="Container 2/3 de l'application Camap (camap-ts)"

RUN adduser --disabled-password --disabled-login --gecos "InterAMAP user" --home /home/interamap interamap

RUN apt-get update && apt-get install -y \
    libconfig-tiny-perl \
    virtual-mysql-client-core \
    procps \
    && apt-get clean && rm -rf /var/lib/apt/lists/*
ENV TZ="Europe/Paris" 
RUN echo "Europe/Paris" > /etc/timezone
COPY --from=builder /srv/ /srv/
COPY ./camap-ts/.env /srv/.env

WORKDIR /srv