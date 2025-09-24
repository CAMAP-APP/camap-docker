# camap-docker

Le package [**camap-docker**](https://github.com/CAMAP-APP/camap-docker) permet une installation simplifiée de Camap pour un environnement de développement.
Il utilise les sources [**camap-hx**](https://github.com/CAMAP-APP/camap-hx) et [**camap-ts**](https://github.com/CAMAP-APP/camap-ts)
des dernières versions publiées sur [CAMAP-APP](https://github.com/CAMAP-APP/camap-docker.git)
qui est également la version de production du [serveur de l'InterAMAP44](https://camap.amap44.org) 

__ℹ️ A noter que l'infrastructure de production déployée par l'InterAMAP44 diffère en ce qu'elle n'utilise pas Traefik mais Nginx comme reverse proxy et s'appuie sur son propre serveur SMTP.__

Camap-docker peut:
- vous permettre d'installer très simplement une version de test sur votre poste local,
- vous aider à configurer, compiler et installer une version de dev sur votre poste
- ou vous inspirer pour installer une version de production.

La présente documentation a été testée sur Debian 11 & Windows 11 et MacOS 15.6 (Apple Silicon).
Tout retour est bienvenu.

## Prérequis

**Installer docker & docker-compose**

_Sur Debian 11_

https://docs.docker.com/engine/install/debian/

_Sur Windows ou Mac_

Installer [Docker Desktop](https://www.docker.com/products/docker-desktop/) et [Github pour windows](https://windows.github.com/)

## Télécharger camap-docker

```git clone https://github.com/CAMAP-APP/camap-docker.git```

## Mettre à jour le fichier hosts

_Windows_: dans ```C:\Windows\System32\drivers\etc```

_Linux, Mac_: dans ```/etc/hosts```

Si une ligne commençant par 127.0.0.1 existe déjà, ajouter en fin de ligne: 
```
camap.localdomain api.camap.localdomain
```

Sinon ajouter la ligne:
```
127.0.0.1 localhost camap.localdomain api.camap.localdomain
```

## Installation

### 1. Installer les sous-projets camap-hx et camap-ts
- ```git submodule update --init --recursive```

### 2. Copier les configurations
- `.env` dans `camap-ts`
- `config.xml` dans `camap-hx`

### 3. Construction des containers
```
docker compose up -d --build
```

### Vérifier que les containers sont bien lancés

A l'aide de la commande ```docker compose ps``` ou via Docker Desktop, vérifier que les containers sont bien lancés.

5 containers doivent être présents:
- camap-docker-reverse-proxy-1
- loc-mysql
- neko-loc-camap
- nest-loc-camap
- mailpit

Au besoin, relancer les containers manquant via la commande "docker compose restart <nom_container>" ou via Docker Desktop

ex: ```docker compose restart neko-loc-camap```

jusqu'à ce que tous les containers soient présents.

### Premier accès à l'application

Le dashboard Traefik est accessible via http://127.0.0.1:8080/

Après l'installation avec les certificats autosignés, un accès via le navigateur à https://api.camap.localdomain est nécessaire pour passer outre l'avertissement de sécurité, sinon les menus gérés par api.camap ne fonctionneront pas.

Ensuite un premier accès à https://camap.localdomain/install est nécessaire pour initialiser la bdd, puis un second accès permet la configuration du compte admin et d'un groupe de démonstration. 

__⚠️Un compte admin est créé avec l'adresse **admin@camap.tld** et le mot de passe **admin**__

### Développement
__⚠️ Si vous installez un environnement de développement, continuez l'installation en suivant la documentation dans [camap-ts/docs/install.md](https://github.com/CAMAP-APP/camap-ts/blob/master/docs/install.md)__

## Configuration

### La configuration du container neko-loc-camap se fait dans _config.xml_ du sous-répertoire camap-hx

- ```key``` doit avoir la même valeur que ```CAMAP_KEY``` dans camap-ts/.env

_Cette clef est utilisée pour vérifier le hash des mots de passe des comptes Camap_

- ```host``` nom d'hôte __publique__ du serveur haxe (camap.localdomain par défaut)

- ```camap_api``` contient l'url du frontal Camap (api.camap.localdomain par défaut)

- ```mapbox_server_token``` contient la clef pour les fonctions de géolocalisation, à créer sur mapbox.com (gratuit jusqu'à 100.000 requetes par mois)

### La configuration du container nest-loc-camap se fait dans _.env_ du sous-répertoire camap-ts

- ```CAMAP_KEY``` doit avoir la même valeur que ```key``` dans camap-hx/config.xml

_Cette clef est utilisée pour vérifier le hash des mots de passe des comptes Camap_

- ```CAMAP_HOST``` contient l'url du serveur haxe camap-hx (camap.localdomain par défaut)

- ```FRONT_URL``` contient l'url du serveur nest (camap-ts)

- ```FRONT_GRAPHQL_URL``` contient l'url de graphql (FRONT_URL/graphql)

- ```MAPBOX_KEY``` contient la clef pour les fonctions de géolocalisation, à créer sur mapbox.com (gratuit jusqu'à 100.000 requetes par mois)

La rubrique _MAIL_ doit être renseignée avec les informations de votre serveur SMTP.

### Emails
En développement, nous recommandons d'utiliser Mailpit, déjà inclus dans `docker-compose.dev.yml`.

1. Lancer Mailpit (automatique avec `docker compose up` en dev).
2. Dans `camap-ts/.env`, configurer:

```
MAILER_TRANSPORT=smtp
SMTP_HOST=mailpit
SMTP_PORT=1025
SMTP_SECURE=false
SMTP_AUTH_USER=mail_user
SMTP_AUTH_PASS=mail_pass
```

Avec ces valeurs, les emails seront capturés par Mailpit et visibles dans l'interface web.

3. Interface: http://localhost:8025
Ici vous pouvez voir tous les mails qui transitent
__⚠️Aucun mail ne sort de votre environnement local, tout est capturé par mailpit__

### Configuration Certificat

L'installation par défaut utilise un certificat autosigné généré avec openssl

Pour automatiser la fourniture d'un certificat letsencrypt personnalisé:

___⚠️ Non testé, à valider ⚠️___

- éditer __traefik.yml__ et décommenter la rubrique suivante (en enlevant le caractètre \#), et modifier l'email: 

```
#certificatesResolvers:
#  le:
#    acme:
#      email: admin@camap.tld
#      storage: /etc/traefik/ssl/acme.json
#      httpChallenge:
#        # used during the challenge
#        entryPoint: web
```

- décommenter les lignes ```traefik.http.routers.nest-loc-camap.tls``` de __docker-compose.yml__

### Traefik

Si vous modifiez les noms d'hôtes par défaut, pensez à éditer le fichier docker-compose.yml en conséquence en remplaçant toutes les occurences de camap.localdomain et api.camap.localdomain.

## Import de données de test en local

Si un environnement de test existe, vous pouvez générer un dump pour avoir des données en local.

L'import peut se faire directement depuis la commande MySQL ou depuis un client comme DBeaver.

Si vous avez des problèmes d'import dû au format binaire des images (unknown command), vous pouvez supprimer les tables (mais pas la DB !) avant de lancer la restauration (si votre dump contient les instructions `CREATE TABLE`)

=> Attention, pour pouvoir supprimer les tables en local, il faut avant tout supprimer les références des tables entre elles.