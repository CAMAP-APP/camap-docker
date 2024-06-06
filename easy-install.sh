#!/bin/bash

# Etapes préalables:
#	- Cloner le dépôt Git CAMAP-APP/camap-docker
# 	- Changer de répertoire pour le dépôt cloné
# Si vous n'avez installé que ce script sans réaliser les étapes préalables,
# décommentez les deux commandes ci-dessous:

#git clone https://github.com/CAMAP-APP/camap-docker.git

#cd camap-docker

# Renommer le fichier docker-compose.yml en docker-compose.orig.yml
mv docker-compose.yml docker-compose.orig.yml

# Renommer le fichier docker-compose.easy.yml en docker-compose.yml
mv docker-compose.easy.yml docker-compose.yml

# Lancer docker-compose en mode détaché
docker-compose up -d