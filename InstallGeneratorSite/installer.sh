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

# Création des fichiers pour le site originel

echo "body {
	background: rgb(255, 255, 255);
	color: rgb(19, 1, 1);
	font-size: larger; 
}

.container {
	max-width: 800px;
}

#title {
	height: 85px;
	margin-top: 20px;
	margin-bottom: 20px;
	padding-top: 20px;
	border: 1px solid;
}

#footer {
	position: fixed;
	width: 100%;
	bottom: 10px;
	left: 0;
	text-align: center;
}

a, .btn-link, a:hover, .btn-link:hover {
	text-decoration: none;
	color: rgb(3, 1, 1);
	font-style: italic;
}
" > "$directory_name/template.css"

echo "html
	head
		meta(charset="utf-8")
		meta(name="viewport",content="width=device-width,initial-scale=1")
		title Test
		link(href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css",rel="stylesheet")
		link(href="/template.css",rel="stylesheet")
	body
		.container
			.row
				.col.text-center
					h1#title Le meilleur site
			.row
				.col
					block content
			div#footer Fait par albi
" > "$directory_name/template.pug"

echo "extends template
block content
	form(action="/generateSite",method="POST")
		.form-group
			label Nom du répertoire :
			input(name="nom").form-control
		.form-group
			label Port
			input(name="port").form-control
		button.btn.btn-link Create
" > "$directory_name/generateSite.pug"


chmod -R a+rwx "$directory_name"/script.sh
chmod -R a+rwx "$directory_name"/template.css
chmod -R a+rwx "$directory_name"/template.pug
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
