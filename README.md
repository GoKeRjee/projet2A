# projet2A
Projet web - 2A

 - IntallGeneratorSite

 Dans ce dossier il y a installer.sh. Ce fichier va contenir tout ce qui est installation des librairie et autres mais il va aussi faire la création des fichier du site de géneration de site.

 Pour lancer l'installeur :

 chmod -R a+rwx installer.sh
 ./installer

A l'execution de l'installeur, un onglet se lancera, mettant à disposition le site.

Comme on est en localhost si on éteint la machine alors le serveur va aussi s'éteindre.
Pour le relancer, il faut ouvrir un terminal dans le répertoire "TheGenerator" et taper la commande suivante :

node server.js & google-chrome http://localhost:3030/


- website_deployment

Ce dossier est enfaite un exemple de ce que va construire le fichier installer.sh. Dans ce dossier le but est de modifier les différents fichier créer par installer.sh pour améliorer le site. Quand on aura fini les modification ici il suffira de réecrire le fichier installer avec les modifications qu'on a fait.