# camap-docker

Script de construction des containers Camap


## Prérequis

La présente documentation a été testée sur Debian 11

**Installer docker & docker-compose**

```apt-get install docker-buildx-plugin docker-ce docker-ce-cli docker-compose-plugin```

https://docs.docker.com/engine/install/debian/


**installer nodejs dans la bonne version (16)**

https://www.rosehosting.com/blog/how-to-install-node-js-and-npm-on-debian-11/

## Configuration

### La configuration du container neko-camap se fait dans __config.xml__ de <DESTDIR>/camap-hx

```key``` doit avoir la même valeur que ```CAMAP_KEY``` dans camap-ts/.env
Cette clef est utilisée pour vérifier le hash des mots de passe des comptes Camap

```host``` nom d'hote sur serveur camap (1er terme de ```camap_api```)

```camap_api``` contient l'url du frontal Camap

```mapbox_server_token``` contient la clef pour les fonctions de géolocalisation, à créer sur mapbox.com (gratuit jusqu'à 100.000 requetes par mois)

### La configuration du container nest-camap se fait dans __.env__ de <DESTDIR>/camap-ts

```CAMAP_KEY``` doit avoir la même valeur que ```key``` dans camap-hx/config.xml
Cette clef est utilisée pour vérifier le hash des mots de passe des comptes Camap

```CAMAP_HOST``` contient l'url du frontal Camap (camap-hx)

```FRONT_URL``` contient l'url du serveur nest (camap-ts)

```FRONT_GRAPHQL_URL``` contient l'url de graphql (FRONT_URL/graphql)

La rubrique _MAIL_ doit être renseignée avec les informations de votre serveur de mail

## Installation

lancer
`build_camap_docker.sh <DESTDIR>`

pour une installation de Camap dans ```DESTDIR```

L'installation est complètement dockerisée, l'édition des sources nécessite de relancer le build des containers

Après l'installation, remonter une sauvegarde via mysqlworkbench ou myloader ou créer le compte admin via https://camap/install

