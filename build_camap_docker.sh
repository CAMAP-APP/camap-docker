#/bin/bash
SRCDIR=$PWD

if [ $# -ne 1 ]
then
     echo "Vous devez préciser le répertoire d'installation"
     echo "ex: \"build_camap_dev.sh /var/CAMAP\" pour une instance dans /var/CAMAP"
     exit 0
fi
DESTDIR=$1

ls $DESTDIR
res=$?

if [ $res -eq 2 ]
then
        mkdir $DESTDIR
        $res2=$?
        if [ $res2 -ne 0 ] 
        then
                echo "Impossible de créer le répertoire d'installation"
                exit 1
        else
                echo "Création de "$DESTDIR" OK"
        fi
elif [ $res -eq 0 ]
        then
                echo "Le répertoire "$DESTDIR" existe déjà."
                echo "Installation"
else
        echo "Erreur"
        exit 1
fi

cd $DESTDIR
echo "Installation des depots camap-hx et camap-ts en sous-modules"
git submodule update --init --recursive
[ $? -ne 0 ] && echo "Erreur d'installation -2" && exit -2

echo "Copie des fichiers de configuration"
echo "config.xml"
cp $SRCDIR/config.xml $DESTDIR/camap-hx/config.xml
[ $? -ne 0 ] && echo "Erreur d'installation -3" && exit -3

echo ".env"
cp $SRCDIR/.env $DESTDIR/camap-ts/.env
[ $? -ne 0 ] && echo "Erreur d'installation -4" && exit -4

echo "camap-hx.Dockerfile camap-ts.Dockerfile mysql.Dockerfile traekif.yml"
cp $SRCDIR/camap-hx.Dockerfile $SRCDIR/camap-ts.Dockerfile $SRCDIR/mysql.Dockerfile $SRCDIR/traefik.yml $DESTDIR
[ $? -ne 0 ] && echo "Erreur d'installation -5" && exit -5

echo "docker-compose.yml"
cp $SRCDIR/docker-compose.yml $DESTDIR/docker-compose.yml
[ $? -ne 0 ] && echo "Erreur d'installation -6" && exit -6

echo "copie de traefik/config"
cp -rp $SRCDIR/traefik $DESTDIR
[ $? -ne 0 ] && echo "Erreur d'installation -7" && exit -7

echo "copie de ssl"
cp -rp $SRCDIR/ssl $DESTDIR
[ $? -ne 0 ] && echo "Erreur d'installation -8" && exit -8

echo "Build des containers..."
echo "vous pouvez aller prendre un café"
cd $DESTDIR
docker compose build

echo "Vous pouvez maintenant démarrer les containers"
echo "à l'aide de la commande: docker compose up -d"
