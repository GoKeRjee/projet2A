#!/bin/bash

# Demander le nom du répertoire
echo "Nom du répertoire : $1"
echo "Port : $2"

directory_name="$1"
port="$2"

# Créer le répertoire s'il n'existe pas déjà
if [ ! -d "$directory_name" ]; then
  mkdir "$directory_name"
fi

cd "$directory_name"/

# Initialiser le dossier en tant que projet Node.js et installer Express

yes "" | npm init
npm install express --save
npm i -D pug


cd ../

cp ./script.sh "$directory_name"/
cp ./generateSite.pug "$directory_name"/
cp ./template.css "$directory_name"/
cp ./template.pug "$directory_name"/
chmod -R a+rwx "$directory_name"/script.sh
chmod -R a+rwx "$directory_name"/generateSite.pug


# Créer le fichier serveur.js
echo "const express = require('express');
const app = express();
const { exec } = require('child_process');
const root = __dirname;
app.use(express.static(root));
const port = "$port";

app.use(express.urlencoded({ extended: true })); // req.body
app.set('view engine','pug');
app.set('views',root);


app.get('/generate', (req, res) => {
  res.render('generateSite');
});

app.post('/generateSite',(req,res)=>{
	var nom = req.body.nom;
	var port = req.body.port;
	exec(root + '/script.sh ' + nom + ' ' + port);
	res.redirect('/generate');
});

app.listen(port, () => {
  console.log(\`Server listening at http://localhost:\${port}\`);
});" > "$directory_name/server.js"

# Confirmer la création des fichiers
echo "Site généré dans le répertoire $directory_name."

node "$directory_name"/server.js
