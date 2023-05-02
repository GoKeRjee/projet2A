# projet2A
## *Projet web - 2A*

### **Intall Generator Site**

 Dans ce dossier il y a un fichier script nommé "installer.sh". Ce script va procéder à l'installation de toutes les librairies nécessaires au fonctionnement du projet. Il va ensuite créer tous les fichiers du projet dans un répertoire.   

 Pour lancer l'installeur :

  - chmod -R a+rwx installer.sh
  - ./installer.sh

A l'execution de l'installeur, un onglet se lancera, mettant à disposition le site.  

Comme nous sommes en localhost, si nous éteignons la machine alors le serveur va lui aussi s'éteindre.  
Pour le relancer, il faut ouvrir un terminal dans le répertoire "TheGenerator" et taper la commande suivante :

node server.js & google-chrome http://localhost:3030/

Si on veut utiliser un autre navigateur il suffit d'aller sur : http://localhost:3030/


### **Website deployment**

Ce dossier est enfaite un exemple de ce que va construire le fichier installer.sh. Dans ce dossier le but est de modifier les différents fichiers crées par le script "installer.sh" pour faire des tests de fonctionnement et améliorer le site. Quand nous aurons fini les modifications ici il suffira de réecrire le fichier installer avec les modifications que nous aurons apporté.

Pour lancer le serveur et tester le bon fonctionnement du site il faut ouvrir le terminal et aller dans ce répertoire puis taper la commande suivante :

  - node server.js & google-chrome http://localhost:3030/

A l'execution de l'installeur, un onglet se lancera, mettant à disposition le site avec directement la page de création de site. Il suffira ensuite d'écrire le nom du répertoire dans lequel on veut créer le site et d'indiquer le port dans lequel sera le site.  
Avant l'appuie du bouton "Create" il faut s'assurer que le serveur MongoDB tourne en tapant sur un terminal la commande :

  - sudo systemctl status mongod

Si cette commande n'affiche pas "active" alors utiliser cette commande pour lancer le serveur : 

  - sudo systemctl start mongod

Après avoir appuyé sur "Create" il faudra attendre le temps des installations et un nouvel onglet s'ouvrira dans le nouveau site que vous venez de créer.
