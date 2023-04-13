# projet2A
## *Projet web - 2A*

### **Intall Generator Site**

 Dans ce dossier il y a installer.sh. Ce fichier va contenir tout ce qui est installation des librairie et autres mais il va aussi faire la création des fichier du site de géneration de site.

 Pour lancer l'installeur :

  - chmod -R a+rwx installer.sh
  - ./installer.sh

A l'execution de l'installeur, un onglet se lancera, mettant à disposition le site.

Comme on est en localhost si on éteint la machine alors le serveur va aussi s'éteindre.
Pour le relancer, il faut ouvrir un terminal dans le répertoire "TheGenerator" et taper la commande suivante :

node server.js & google-chrome http://localhost:3030/

Si on veut utiliser un autre navigateur il suffit d'aller sur : http://localhost:3030/


### **Website deployment**

Ce dossier est enfaite un exemple de ce que va construire le fichier installer.sh. Dans ce dossier le but est de modifier les différents fichier créer par installer.sh pour faire des tests de fonctionnement et améliorer le site. Quand on aura fini les modification ici il suffira de réecrire le fichier installer avec les modifications qu'on a fait.

Pour lancer le serveur et tester le bon fonctonnement du site il faut ouvrir le terminal et aller dans ce répertoire puis taper la commande suivante :

  - node server.js & google-chrome http://localhost:3030/

A l'execution de l'installeur, un onglet se lancera, mettant à disposition le site avec directement la page de création de site. Il suffira ensuite d'écrire le nom du répertoire dans lequel on veut créer le site et d'indiquer le port dans lequel sera le site.
Avant l'appuie du bonton "Create" il faut s'assurer que le serveur MongoDB tourne en tapant sur un terminal la commande :

  - sudo systemctl status mongod

Si cette commande n'affiche pas "active" alors utiliser cette commande pour lancer le serveur : 

  - sudo systemctl start mongod

Après avoir appuiyé sur "Create" il faudra attendre le temps des installations et un nouvel onglet s'ouvrira dans le nouveau site que vous venez de créer.