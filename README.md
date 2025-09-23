# camap-docker

Le package [**camap-docker**](https://github.com/CAMAP-APP/camap-docker) permet une installation simplifiée de Camap sur une machine Windows ou Linux (ou autre mais non testé). Il utilise les sources [**camap-hx**](https://github.com/CAMAP-APP/camap-hx) et [**camap-ts**](https://github.com/CAMAP-APP/camap-ts) des dernières versions publiées sur [CAMAP-APP](https://github.com/CAMAP-APP/camap-docker.git) qui est également la version de production du [serveur de l'InterAMAP44](https://camap.amap44.org) 

A noter que l'infrastructure de production déployée par l'InterAMAP44 diffère en ce qu'elle n'utilise pas Traefik mais Nginx comme reverse proxy et s'appuie sur son propre serveur SMTP.

Camap-docker peut:
- vous permettre d'installer très simplement une version de test sur votre poste local,
- vous aider à configurer, compiler et installer une version de dev sur votre poste
- ou vous inspirer pour installer une version de production.

La présente documentation a été testée sur Debian 11 & Windows 11 et MacOS 15.6 (Apple Silicon).
Tout retour est bienvenue.

## Prérequis

**Installer docker & docker-compose**

_Sur Debian 11_

https://docs.docker.com/engine/install/debian/

_Sur Windows_ 

Installer [Docker Desktop](https://www.docker.com/products/docker-desktop/) et [Github pour windows](https://windows.github.com/)

# Première étape: télécharger camap-docker

Script de construction des containers Camap

```git clone https://github.com/CAMAP-APP/camap-docker.git```

# Option 1: Installation facile et non paramétrable pour tester Camap en local

__Camap for dummies__

Cette installation vous permet d'installer facilement Camap sur un poste de travail.

Elle s'appuie sur la dernière release stable des images docker CAMAP-APP et ne nécessite pas de compilation.

⚠️ dans cette configuration, les mails issus de la messagerie Camap ne sont pas envoyés

### Mettre à jour le fichier hosts

_Windows_: dans ```C:\Windows\System32\drivers\etc```

_Linux_: dans ```/etc/hosts```

Si une ligne commençant par 127.0.0.1 existe déjà, ajouter en fin de ligne: 

	camap.localdomain api.camap.localdomain

Sinon ajouter la ligne:

	127.0.0.1 localhost camap.localdomain api.camap.localdomain

### Exécuter le script easy-install

Aller dans le répertoire camap-docker:

	cd camap-docker

Lancer le script:

Windows_:

	powershell ./easy-install.ps1

_Linux_:

	chmod u+x easy-install.sh
	./easy-install.sh

### Vérifier que les containers sont bien lancés

A l'aide de la commande ```docker compose ps``` ou via Docker Desktop, vérifier que les containers sont bien lancés.

4 containers doivent être présents:
- camap-docker-reverse-proxy-1
- loc-mysql
- neko-loc-camap
- nest-loc-camap

Au besoin, relancer les containers manquant via la commande "docker compose restart <nom_container>" ou via Docker Desktop

ex: ```docker compose restart neko-loc-camap```

jusqu'à ce que tous les containers soient présents.

### Premier accès à l'application

Le dashboard Traefik est accessible via http://127.0.0.1:8080/

Après l'installation avec les certificats autosignés, un accès via le navigateur à https://api.camap.localdomain est nécessaire pour passer outre l'avertissement de sécurité, sinon les menus gérés par api.camap ne fonctionneront pas.

Ensuite un premier accès à https://camap.localdomain/install est nécessaire pour initialiser la bdd, puis un second accès permet la configuration du compte admin et d'un groupe de démonstration. 

Ce compte admin est créé avec l'adresse 'admin@camap.tld' et le mot de passe 'admin'

### Quelques commandes docker-compose de base 
Pour arrêter Camap: 	
```docker compose down```

Pour lancer Camap: 
```docker compose up```

Pour voir les logs: 
```docker compose logs```

Pour voir les logs en continu: 
```docker compose logs -f```


# Option 2: Installation avancée configurable

## Installation Linux Debian

lancer
```build_camap_docker.sh <DESTDIR>```

pour une installation de Camap dans `DESTDIR`

Renseigner le DNS ou votre fichier hosts avec les valeurs correspondantes à la configuration.

Pour une installation en local avec les valeurs par défaut:
```
	127.0.0.1 camap.localdomain api.camap.localdomain
```

## Installation sous Windows

Installer docker desktop

Cloner ce repo
puis lancer
- ```git submodule update --init --recursive```

Copier les configurations suivantes:
- `.env` dans `camap-ts`
- `config.xml` dans `camap-hx`

Renseigner le DNS ou votre fichier hosts (c:\windows\system32\drivers\etc) avec les valeurs correspondante à la configuration.

Pour une installation en local avec les valeurs par défaut:
```
	127.0.0.1 camap.localdomain api.camap.localdomain loc-mysql
```

### Traefik

Si vous modifiez les noms d'hôtes par défaut, pensez à éditer le fichier docker-compose.yml en conséquence en remplaçant toutes les occurences de camap.localdomain et api.camap.localdomain.

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

En développement, nous recommandons d'utiliser Mailpit, déjà inclus dans `docker-compose.dev.yml`.

1. Lancer Mailpit (automatique avec `docker compose up` en dev). Interface: http://localhost:8025
2. Dans `camap-ts/.env`, configurer:

```
MAILER_TRANSPORT=smtp
SMTP_HOST=mailpit
SMTP_PORT=1025
SMTP_SECURE=false
SMTP_AUTH_USER=
SMTP_AUTH_PASS=
```

Avec ces valeurs, les emails seront capturés par Mailpit et visibles dans l'interface web.


### Configuration Certificat

___⚠️ Non testé, à valider ⚠️___

L'installation par défaut utilise un certificat autosigné généré avec openssl

Pour automatiser la fourniture d'un certificat letsencrypt personnalisé:

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

__⚠️ Si vous voulez installer une configuration de développement sur votre machine, arrêtez ici et continuez l'installation en suivant la documentation dans [camap-ts/docs/install.md](https://github.com/CAMAP-APP/camap-ts/blob/master/docs/install.md)__

### Construction des containers

Exécuter ```docker compose up -d --build```


### Import de données de test en local

Si un environnement de test existe, vous pouvez générer un dump pour avoir des données en local.

L'import peut se faire directement depuis la commande MySQL ou depuis un client comme DBeaver.

Si vous avez des problèmes d'import dû au format binaire des images (unknown command), vous pouvez supprimer les tables (mais pas la DB !) avant de lancer la restauration (si votre dump contient les instructions `CREATE TABLE`)

=> Attention, pour pouvoir supprimer les tables en local, il faut avant tout supprimer les références des tables entre elles.

### Accès à l'application

Le dashboard Traefik est accessible via http://127.0.0.1:8080/dashboard/

Après l'installation avec les certificats autosignés, un accès via le navigateur à https://api.camap.localdomain est nécessaire pour passer outre l'avertissement de sécurité, sinon les menus gérés par api.camap ne fonctionneront pas.

Ensuite un premier accès à https://camap.localdomain/install est nécessaire pour initialiser la bdd, puis un second accès permet la configuration du compte admin et d'un groupe de démonstration. 

Ce compte admin est créé avec l'adresse 'admin@camap.tld' et le mot de passe 'admin'