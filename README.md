# camap-docker

Le package [**camap-docker**](https://github.com/CAMAP-APP/camap-docker) permet une installation simplifiée de Camap sur une machine Windows ou Linux (ou autre mais non testé). Il utilise les sources [**camap-hx**](https://github.com/CAMAP-APP/camap-hx) et [**camap-ts**](https://github.com/CAMAP-APP/camap-ts) des dernières versions publiées sur [CAMAP-APP](https://github.com/CAMAP-APP/camap-docker.git) qui est également la version de production du [serveur de l'InterAMAP44](https://camap.amap44.org) 

A noter que l'infrastructure de production déployée par l'InterAMAP44 diffère en ce qu'elle n'utilise pas Traefik mais Nginx comme reverse proxy.

# Construction des containers depuis les sources

Script de construction des containers Camap

```git clone https://github.com/CAMAP-APP/camap-docker.git```

## Prérequis

La présente documentation a été testée sur Debian 11 & Windows 11

**Installer docker & docker-compose**

_Sur Debian 11_

```apt-get install docker-buildx-plugin docker-ce docker-ce-cli docker-compose-plugin```

https://docs.docker.com/engine/install/debian/

_Sur Windows_

Installer [Docker Desktop](https://www.docker.com/products/docker-desktop/) et [Github pour windows](https://windows.github.com/)


## Installation Linux Debian

lancer
`build_camap_docker.sh <DESTDIR>`

pour une installation de Camap dans ```DESTDIR```

Renseigner le DNS ou votre fichier hosts avec les valeurs correspondante à la configuration.
Pour une installation en local:

```127.0.0.1 camap.localdomain api.camap.localdomain```

#### Modifier les lignes 3 à 7 de __camap-ts.Dockerfile__ dans $DESTDIR avec les valeurs indiquées dans __camap-ts/.env__



## Installation sous Windows

Installer docker desktop

Créer un répertoire Camap

Dans ce répertoire:

- ```git clone https://github.com/CAMAP-APP/camap-hx.git```

- ```git clone https://github.com/CAMAP-APP/camap-ts.git```

- ```git clone https://github.com/CAMAP-APP/camap-docker.git```


Copier ensuite depuis camap/camap-docker/:

- ```traefik.yml``` dans ```camap```

- ```*.Dockerfile``` dans ```camap```

- ```docker-compose.yml``` dans ```camap```

- ```.env``` dans ```camap/camap-ts```

- ```config.xml``` dans ```camap/camap-hx```

- le répertoire ```traefik``` et son contenu dans ```camap```

- le répertoire ```ssl``` et son contenu dans ```camap```

Renseigner le DNS ou votre fichier hosts (c:\windows\system32\drivers\etc) avec les valeurs correspondante à la configuration.

Pour une installation en local:

```127.0.0.1 camap.localdomain api.camap.localdomain loc-mysql```

## Configuration

### La configuration du container neko-camap se fait dans __config.xml__ de $DESTDIR/camap-hx

- ```key``` doit avoir la même valeur que ```CAMAP_KEY``` dans camap-ts/.env
Cette clef est utilisée pour vérifier le hash des mots de passe des comptes Camap

- ```host``` nom d'hote sur serveur camap (1er terme de ```camap_api```)

- ```camap_api``` contient l'url du frontal Camap

- ```mapbox_server_token``` contient la clef pour les fonctions de géolocalisation, à créer sur mapbox.com (gratuit jusqu'à 100.000 requetes par mois)

### La configuration du container nest-camap se fait dans __.env__ de $DESTDIR/camap-ts

- ```CAMAP_KEY``` doit avoir la même valeur que ```key``` dans camap-hx/config.xml
Cette clef est utilisée pour vérifier le hash des mots de passe des comptes Camap

- ```FRONT_URL``` contient l'url du serveur nest (camap-ts)

- ```FRONT_GRAPHQL_URL``` contient l'url de graphql (FRONT_URL/graphql)

- ```MAPBOX_KEY``` contient la clef pour les fonctions de géolocalisation, à créer sur mapbox.com (gratuit jusqu'à 100.000 requetes par mois)

La rubrique _MAIL_ doit être renseignée avec les informations de votre serveur SMTP

A des fins de test, vous pouvez créer un compte sur https://ethereal.email/create

(avec un compte ethereal.email, laissez SMTP_SECURE=false et renseignez SMTP_AUTH_USER & SMTP_AUTH_PASS en fonction)

```
MAILER_TRANSPORT=smtp 
SMTP_HOST=smtp.ethereal.email
SMTP_PORT=587
SMTP_SECURE=false
SMTP_AUTH_USER=
SMTP_AUTH_PASS=
```


### Configuration Certificat

___A VALIDER___

L'installation par défaut utilise un certificat autosigné généré avec openssl

Pour automatiser la fourniture d'un certificat letsencrypt personnalisé:

- éditer __traefik.yml__ et décommenter la rubrique suivante (en enlevant le caractètre \#), et modifier l'email: 

```
#certificatesResolvers:
#  le:
#    acme:
#      email: admin@camap.localdomain
#      storage: /etc/traefik/ssl/acme.json
#      httpChallenge:
#        # used during the challenge
#        entryPoint: web
```

- décommenter les lignes ```traefik.http.routers.nest-loc-camap.tls``` de __docker-compose.yml__


⚠️ Si vous voulez installer sur votre machine, arrêtez ici et continuez l'installation en suivant la documentation dans camap-ts/docs/install.md 

## Construction des containers

exécuter ```docker compose up -d --build```


## Import de données de test en local

Si environnement de test existe, vous pouvez générer un dump pour avoir des données en local.

L'import peut se faire directement depuis la commande MySQL ou depuis un client comme DBeaver.

Si vous avez des problèmes d'import dû au format binaire des images (unknown command), vous pouvez supprimer les tables (mais pas la DB !) avant de lancer la restauration (si votre dump content les instructions `CREATE TABLE`)

=> Attention, pour pouvoir supprimer les tables en local, il faut avant tout supprimer les références des tables entre elles.

## Accès à l'application

Le dashboard Traefik est accessible via http://127.0.0.1:8080/dashboard/

Après l'installation avec les certificats autosignés, un accès via le navigateur à https://api.camap.localdomain est nécessaire pour passer outre l'avertissement de sécurité, sinon les menus gérés par api.camap ne fonctionneront pas.

Ensuite un premier appel à https://camap.localdomain/install est nécessaire pour initialiser la bdd.