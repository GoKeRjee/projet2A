#!/bin/bash

#This script is an installer that will set up a site from which it will be possible to create and control others in a few clicks. 
#A certain number of modules and packages will be installed, then the site files as well as the static resources.

# Update the package lists
sudo apt-get update -y

# Function to check if a command is available
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Check if Curl is installed
if ! command_exists curl; then
  echo "Curl is not installed. Installing..."
  # Install Curl
  sudo apt install curl
else
  echo "Curl is already installed."
fi

# Check if MongoDB is installed
if ! command_exists mongod; then
  echo "MongoDB is not installed. Installing..."

  # Install MongoDB
  sudo apt-get install gnupg
  curl -fsSL https://www.mongodb.org/static/pgp/server-6.0.asc | sudo gpg --dearmor --output /usr/share/keyrings/mongodb-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/mongodb-archive-keyring.gpg] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list
  sudo apt-get update
  sudo apt-get install -y mongodb-org

  echo "mongodb-org hold" | sudo dpkg --set-selections
  echo "mongodb-org-database hold" | sudo dpkg --set-selections
  echo "mongodb-org-server hold" | sudo dpkg --set-selections
  echo "mongodb-mongosh hold" | sudo dpkg --set-selections
  echo "mongodb-org-mongos hold" | sudo dpkg --set-selections
  echo "mongodb-org-tools hold" | sudo dpkg --set-selections

  echo "MongoDB installed successfully."
else
  echo "MongoDB is already installed."
fi

# Check if Node.js is installed
if ! command_exists node; then
  echo "Node.js is not installed. Installing..."

  # Check if nvm is installed
  if ! command_exists nvm; then
    echo "nvm is not installed. Installing..."
    # Install nvm (Node Version Manager)
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
    # Load nvm into the script
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    echo "nvm installed successfully."
  else
    echo "nvm is already installed."
  fi
  # Install the latest version of Node.js
  nvm install node
  echo "Node.js installed successfully."
else
  echo "Node.js is already installed."
fi

# Check if npm is installed
if ! command_exists npm; then
  echo "Npm is not installed. Installing..."
# Install npm
  sudo apt install -y npm
else
  echo "Npm is already installed."
fi

# Check if fuser is installed
if ! command_exists fuser; then
  echo "fuser is not installed. Installing..."
  # Install fuser
  sudo apt install -y psmisc
  echo "fuser installed successfully."
else
  echo "fuser is already installed."
fi

# Check installed versions
echo "Installed versions:"
mongod --version
node --version
npm --version
fuser --version

# Start the MongoDB service
sudo systemctl start mongod

# The name of the directory in whiwh we create the files
directory_name="TheGenerator"

# Create the directory if it does not already exist
if [ ! -d "$directory_name" ]; then
  mkdir "$directory_name"
fi

# Initialise the folder as a Node.js project and install Express
cd "$directory_name"/
npm init -y
npm install express --save
npm install net --save
npm install child_process --save
npm install monk --save
npm install bcryptjs --save
npm install express-validator --save
npm install jsonwebtoken --save
npm install cookie-parser --save
npm install dotenv --save
npm install pug --save
cd ../

# Create the script file which will make it possible to create other sites
cat << 'EOF' > "$directory_name/script.sh"
#!/bin/bash

# Ask for the directory name
echo "Directory name: $1"
echo "Port : $2"
echo "Website name : $3"
echo "DB name : $4"

directory_name="$1"
port="$2"
website_name="$3"
db_name="$4"

# Create the path if not exist
if [ ! -d "$directory_name" ]; then
  mkdir "$directory_name"
fi

cd "$directory_name"/

# Installation of tools
yes "" | npm init
npm install express --save
npm install pug --save
npm install markdown-it --save
npm install multer --save
npm install monk --save

cd ../

# Creation of the css template file
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

#footer{
	text-align: center;
	padding: 20px;
	color: dark;
	margin-top : 15px;
	bottom: 0; left: 0; right: 0;
	position: fixed;
}" > "$directory_name/template.css"

# Creation of the template file
echo "html
	head
		meta(charset='utf-8')
		meta(name='viewport',content='width=device-width,initial-scale=1')
		title <LOGO>
		link(href='https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css',rel='stylesheet')
		link(href='/template.css',rel='stylesheet')
	body
		.container
			.row
				.col.text-center
					h1#title <HEADER>
			.row
				.col
					block content
			div#footer <FOOTER>" > "$directory_name/template"


# Creation of the template.pug file
echo "html
	head
		meta(charset='utf-8')
		meta(name='viewport',content='width=device-width,initial-scale=1')
		title $website_name
		link(href='https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css',rel='stylesheet')
		link(href='/template.css',rel='stylesheet')
	body
		.container
			.row
				.col.text-center
					h1#title $website_name
			.row
				.col
					block content
			div#footer &copy; Copyright 2023 - albi.grainca@uha.fr - batuhan.goker@uha.fr" > "$directory_name/template.pug"

# Creation of the page.pug file
echo "extends template
block content
	!= content
	a(href='/pageedit/'+name) edit" > "$directory_name/page.pug"

# Creation of the pageedit.pug file
echo "extends template
block content
	form(action='/pageedit',method='POST')
		input(name='name',value=name,type='hidden')
		textarea(name='content',rows=15).form-control= content
		button.btn.btn-link save" > "$directory_name/pageedit.pug"

# Creation of the pages.pug file
echo "extends template
block content
	ul
		each page in pages
			li
				a(href='/page/'+page.name)=page.name
				|  (
				a(href='/pagedel/'+page.name) del
				| )
		li(style='list-style-type:none')
			a(href='/pagenew') new" > "$directory_name/pages.pug"

# Creation of the pagenew.pug file
echo "extends template
block content
	form(action='/pagenew',method='POST')
		.form-group
			label Name
			input(name='name').form-control
		.form-group
			label Content
			textarea(name='content',rows=15).form-control
		button.btn.btn-link save" > "$directory_name/pagenew.pug"

# Creation of the files.pug file
echo "extends template
block content
	ul
		each file in files
			li
				a(href='/'+file)=file
		li(style='list-style-type:none')
			a(href='/upload') upload" > "$directory_name/files.pug"

# Creation of the upload.pug file
echo "extends template
block content
	form(action='/upload',method='POST',enctype='multipart/form-data')
		input(name='file',type='file').form-control
		button.btn.btn-link upload" > "$directory_name/upload.pug"

# Creation of the config.sh file
echo '#!/bin/bash

# Use the sed command to replace placeholders in the template file
sed -e "s#<LOGO>#$1#g" -e "s#<HEADER>#$2#g" -e "s#<FOOTER>#$3#g" $4/template > $4/template.pug' > "$directory_name/config.sh"

# Creation of the config.pug file
echo "extends template
block content
	form(action='/config',method='POST')
		.form-group
			label Logo
			input(name='logo').form-control
		.form-group
			label Header
			input(name='header').form-control
		.form-group
			label Footer
			input(name='footer').form-control
		button.btn.btn-link update" > "$directory_name/config.pug"

# Give all permisions for this files
chmod -R a+rwx "$directory_name"/config.sh
chmod -R a+rwx "$directory_name"/template
chmod -R a+rwx "$directory_name"/template.pug

# Creation of the serveur.js file
echo "const express = require('express');
const app = express();
const root = __dirname;
app.use(express.static(root));
const port = "$port";

app.use(express.urlencoded({ extended: true })); // req.body
app.set('view engine','pug');
app.set('views',root);

var db = require('monk')('127.0.0.1:27017/$db_name');
var pages = db.get('pages'); 

var md = require('markdown-it')({html:true});


// PAGES
app.get('/page/:name',(req,res)=>{
	var name = req.params.name;
	pages.findOne({'name':name}).then(page=>{
		res.render('page',{'name':page.name,'content':md.render(page.content)});
	});
});

app.get('/pageedit/:name',(req,res)=>{
	var name = req.params.name;
	pages.findOne({'name':name}).then(page=>{
		res.render('pageedit',page);
	});
});

app.post('/pageedit',(req,res)=>{
	var page = req.body;
	pages.update({'name':page.name},{"'$set'":page}).then(()=>{
		res.redirect('/page/'+page.name);
	});
});

app.get('/pages',(req,res)=>{
	pages.find().then(pages=>{
		res.render('pages',{'pages':pages});
	});
});

app.get('/pagenew',(req,res)=>{
	res.render('pagenew');
});

app.post('/pagenew',(req,res)=>{
	var page = req.body;
	pages.insert(page).then(()=>{
		res.redirect('/page/'+page.name);
	});
});

app.get('/pagedel/:name',(req,res)=>{
	var name = req.params.name;
	pages.remove({'name':name}).then(()=>{
		res.redirect('/pages');
	});
});

app.get('/',(req,res)=>{
	res.redirect('/pages');
});

// FILES
var fs     = require('fs');
var multer = require('multer');
var store  = multer.diskStorage({
	destination: function (req, file, cb) { cb(null, root) },
	filename: function (req, file, cb) { cb(null, file.originalname) }
});

var upload = multer({storage:store});

app.get('/files',(req,res)=>{
	var files = fs.readdirSync(root);
	res.render('files',{'files':files});
});

app.get('/upload',(req,res)=>{
	res.render('upload');
});

app.post('/upload',upload.single('file'),(req,res)=>{
	res.redirect('/files');
});

// SCRIPTS
const { exec } = require('child_process');
app.get('/config',(req,res)=>{
	res.render('config');
});

app.post('/config',(req,res)=>{
	var logo   = req.body.logo;
	var header = req.body.header;
	var footer = req.body.footer;
	exec(root+'/config.sh ' + logo +' ' + header + ' '+ footer + ' ' + root);
	res.redirect('/');
});

app.listen(port, () => {
	console.log(\`Server listening at http://localhost:\${port}\`);
});" > "$directory_name/server.js"

# Confirm the creation of the folders
echo "Site généré dans le répertoire $directory_name."

# Launch the service
node "$directory_name"/server.js &
sleep 2
firefox http://localhost:$port/
EOF

#########################################
# Create the script that allows to start a site
cat << 'EOF' > "$directory_name/start.sh"
#!/bin/bash

# Check if the number of arguments is correct
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <path/to/server.js>  <port>"
    exit 1
fi

# Store the directory name and port from the command-line arguments
directory_name="$1"
port="$2"

# Start the server.js script
node "$directory_name"/server.js & 
sleep 2
firefox http://localhost:$port/
EOF

######################
# Create the script that allows to stop a site
cat << 'EOF' > "$directory_name/stop.sh"
#!/bin/bash

# Check if the command-line argument for port is provided
if [ -z "$1" ]
then
  echo "Usage: $0 <port>"
  exit 1
fi

# Store the port value from the command-line argument
port="$1"

# Find and kill the process running on the specified port
pid=$(fuser -n tcp -k $port 2> /dev/null)

# Check if the process has been found and killed
if [ -n "$pid" ]
then
  echo "Processus arrêté avec succès (PID : $pid)"
else
  echo "Aucun processus en cours d'exécution sur le port $port"
fi
EOF

#############################
# Create the script that allows to delete a site
cat << 'EOF' > "$directory_name/delete.sh"
#!/bin/bash
# Check if an argument has been supplied
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <directory_to_delete>"
    exit 1
fi

# Retrieve the supplied argument (the directory to be deleted)
directory_to_delete=$1

# Check if the directory exists
if [ ! -d "$directory_to_delete" ]; then
    echo "Error: The directory $directory_to_delete does not exist."
    exit 1
fi

# Delete the contents of the specified directory
echo "Deleting the contents of $directory_to_delete..."
rm -r "${directory_to_delete:?}"/*

# Delete the directory itself
echo "Deleting of $directory_to_delete..."
rmdir "${directory_to_delete:?}"

# Check if the deletion was successful
if [ $? -eq 0 ]; then
    echo "The contents of $directory_to_delete have been successfully deleted."
else
    echo "An error occurred while deleting the contents of $directory_to_delete."
    exit 1
fi
EOF

#####################################
# Create the script that allows to update a site
cat << 'EOF' > "$directory_name/update.sh"
#!/bin/bash

# Check if the number of arguments is correct
if [ "$#" -ne 4 ]; then
  echo "Usage: $0 <path/to/directory> <oldPort> <newPort> <newName>"
  exit 1
fi

# Store the command-line arguments in variables
directory="$1"
old_port="$2"
new_port="$3"
new_name="$4"

# Stop the site using the old port
fuser -k $old_port/tcp

# Modify the port in the server.js file
sed -i "s/$old_port/$new_port/g" "$directory/server.js"

# Escape special characters in the new name
escaped_new_name=$(echo "$new_name" | sed -e 's/[\/&]/\\&/g')

# Modify the title in the template.pug file
sed -i "s/\(^[\t ]*h1#title\).*\$/\1 $escaped_new_name/" "$directory/template.pug"
sed -i "s/\(^[\t ]*title\).*\$/\1 $escaped_new_name/" "$directory/template.pug"

# Start the site with the new port
node "$directory/server.js" &
sleep 2
firefox http://localhost:$new_port/
EOF

# Creation of files for the original site
#####################################
# Create the CSS file

cat << 'EOF' > "$directory_name/template.css"
/*========================================================================
                         Default Font Configuration
========================================================================*/

/*========================================================================
                         Body Configuration
========================================================================*/
body{
	font-family: sans-serif;
	background-color: #E4E4E4;
	text-align : center;
}
/*========================================================================
                         NavBar Styling
========================================================================*/
.active-green {
  background-color: #04AA6D;
}

.ul-navbar {
  list-style-type: none;
  margin: 0;
  padding: 0;
  overflow: hidden;
  background-color: #333;
  display: flex;
}

li {
  border-right: 1px solid #bbb;
  float: left; 
}

li:last-child {
  border-right: none;
}

.right-float {
	margin-left: auto;
}

.right-float ul {
	list-style-type: none;
	padding: 0;
	margin: 0;
}

li a {
  display: block;
  color: white;
  text-align: center;
  font-weight: bold;
  padding: 13px;
  min-width: 140px;
  text-decoration: none;
}

li a:hover {
  background-color: #111;
}

#log-link{
	background-color: #008CBA;
	min-width: 50px;
}

#log-link:hover{
	background-color: #197390;
}

#logout-link{
	background-color: #c3292e;
	min-width: 50px;
}

#logout-link i, #log-link i {
	font-size: 20px;
	transition: transform 0.5s;
}

#logout-link:hover{
	background-color: #910b0b;
}

#logout-link:hover i, #log-link:hover i {
	transform: scale(1.2); /* Agrandit l'icône de 20% lors du survol. */
}


#home-link {
	min-width: 50px;
}

#home-link i{
	font-size: 20px;
	transition: transform 0.5s;
}

#home-link:hover i {
	transform: scale(1.2); /* Agrandit l'icône de 20% lors du survol. */
}


h1{
	margin-top: 40px;
	text-align: center;
	text-decoration: underline;
}

.form{
	margin-top: 50px;
	width: 500px;
	margin-left: auto;
	margin-right: auto;
	color: white;
	padding: 5px;
	margin-bottom: 5px;
	text-align: left;
	background-color: #333;
    border-radius: 8px;
    border-style: solid;
    border-color: white;
	padding: 30px;
	transition: transform 0.5s ease;
}

.center{
	text-align:center;
}
/*======================================================================
                          Button styling
=======================================================================*/
#button-submit{
  background-color: #4CAF50; /* Green */
  border: none;
  color: white;
  padding: 10px 13px;
  margin-top: 10px;
  text-align: center;
  text-decoration: none;
  display: inline-block;
  font-size: 16px;
}

#button-submit:hover{
	filter: brightness(0.85);
}

.button-style-red{
  background-color: #f44336; /* Red */
  border: none;
  color: white;
  padding: 10px 13px;
  margin-top: 10px;
  text-align: center;
  text-decoration: none;
  display: inline-block;
  font-size: 16px;
}

.button-style-red:hover{
	filter: brightness(0.85);
}

.button-style-yellow{
  background-color: #FF9933; /* Yellow */
  border: none;
  color: white;
  padding: 10px 13px;
  margin-top: 10px;
  text-align: center;
  text-decoration: none;
  display: inline-block;
  font-size: 16px;
}

.button-style-yellow:hover{
	filter: brightness(0.85);
}

.button-style-blue{
  background-color: #008CBA; /* Blue */
  border: none;
  color: white;
  padding: 10px 13px;
  margin-top: 10px;
  text-align: center;
  text-decoration: none;
  display: inline-block;
  font-size: 16px;
}

.button-style-blue:hover{
	filter: brightness(0.85);
}

.button-login{
	background-color: #008CBA; /* Blue */
	border: none;
	color: white;
	padding: 15px 13px;
	margin-top: 10px;
	text-align: center;
	text-decoration: none;
	display: inline-block;
	font-size: 16px;
	border-radius: 8px;
	width: 100%;
	font-weight: bold;
  }
  
  .button-login:hover{
	  filter: brightness(0.85);
  }

  .button-register{
	background-color: green;
	border: none;
	color: white;
	padding: 15px 13px;
	margin-top: 10px;
	text-align: center;
	text-decoration: none;
	display: inline-block;
	font-size: 16px;
	border-radius: 8px;
	width: 96%;
	font-weight: bold;
  }
  
  .button-register:hover{
	  filter: brightness(0.85);
  }

.form-test-set-name{
	color: black;
	background-color: white;
	border-radius: 8px;
	border-style: solid;
	border-color: white;
	padding: 5px;
	margin-bottom: 5px;
}
.refresh-button {
	display: inline-block;
	background-color: #4CAF50; /* Green */
	border: none;
	color: white;
	padding: 20px 20px;
	text-align: center;
	text-decoration: none;
	font-size: 14px;
	position: absolute;
	top: 55px;
	right: 10px;
}

.delete-button {
	background: none;
	border: none;
	padding: 0;
	cursor: pointer;
}
  
.delete-button i {
	color: red;
	font-size: 20px;
	padding: 10px;
	transition: transform 0.5s;
}

.delete-button:hover i {
	transform: scale(1.2); /* Agrandit l'icône de 20% lors du survol. */
}


/*======================================================================
                          Index styling
=======================================================================*/
#welcome-message{
	flex: 1;
	flex-grow: 6;
	flex-basis: 50%;
	text-align: justify;
	width: 70%;
	margin-left: 3%;
	margin-right: 1%;
    color: white;
	background-color: #333;
	border-style: solid;
	border: 3px solid;
	border-color: white;
	font-size: 115%;
	border-radius: 8px;
	padding: 46px;
	box-shadow: 0px 4px 6px rgba(0, 0, 0, 0.3);
	transition: transform 0.5s ease;
}

#welcome-message:hover, .index-login:hover {
	transform: scale(1.05);
  }

#welcome-logo{
	width: 250px;
	height: 200px;
}

#inge{
	width: 90px;
	height: 80px;
	position: absolute;
	margin-left: 870px;
	margin-top: -20px;
}

#inge-me{
	width: 90px;
	height: 80px;
	position: absolute;
	margin-left: 970px;
	margin-top: -20px;
}

#welcome-title{
	text-align: center;
	text-decoration: underline;
	font-size: 120%;
	font-weight: bold;
}

.texteBlue{
	color: #00FF61;
	font-weight: bold;
}

.texteRed{
	color: red;
	font-weight: bold;
}

#me{
	text-align: justify;
	width: auto;
	margin-left: auto;
	margin-right: auto;
    color: white;
	background-color: #333;
	border-style: solid;
	border: 3px solid;
	border-color: white;
	font-size: 115%;
	border-radius: 8px;
	padding: 46px;
	box-shadow: 0px 4px 6px rgba(0, 0, 0, 0.3);
}
/*========================================================================
                         List tab styling
========================================================================*/
.tableau-style{
	border-collapse: collapse;
	min-width: 400px;
	width: auto; 
	box-shadow: 0, 5px, 50px, rgba(0,0,0,0.15);
	cursor: pointer;
	margin: 100px auto;
	border: 2px solid #04AA6D;
}

thead tr{
	background-color: #04AA6D;
	color: white;
	text-align: left;
}

th,td{
	padding: 15px 20px;
}

tbody tr, td, th{
	border: 1px solid #ddd;
}

tbody tr:nth-child(even){
	background-color: white;
}

.form-inline {
	display: inline-block;
	margin-right: 5px;
  }

  .netstat{
	font-weight: bold;
  }
  
.tables-container {
	display: flex;
	justify-content: space-around;
}
  
.table-container {
	width: 45%; /* ajustez cette valeur en fonction de vos besoins */
}
  
.table-container:first-child {
	border-right: 2px solid #dadde1;
	padding-right: 20px; /* ajouter un espace à droite du tableau */
}
  
.table-container:last-child {
	padding-left: 20px; /* ajouter un espace à gauche du tableau */
}
  
/*========================================================================
                         Footer styling
========================================================================*/
footer{
  text-align: center;
  padding: 20px;
  background-color: #333;
  color: white;
  margin-top : 15px;
  bottom: 0; left: 0; right: 0;
  position: fixed;
}
/*========================================================================
                         Form styling
========================================================================*/
input[type=text], select {
	width: 100%;
	padding: 12px 20px;
	margin: 8px 0;
	display: inline-block;
	border: 1px solid #ccc;
	border-radius: 4px;
	box-sizing: border-box;
  }

  input[type=password], select {
	width: 100%;
	padding: 12px 20px;
	margin: 8px 0;
	display: inline-block;
	border: 1px solid #ccc;
	border-radius: 4px;
	box-sizing: border-box;
  }
  
  input[type=submit] {
	width: 100%;
	background-color: #4CAF50;
	color: white;
	padding: 14px 20px;
	margin: 8px 0;
	border: none;
	border-radius: 4px;
	cursor: pointer;
  }
  
  input[type=submit]:hover {
	background-color: #45a049;
  }
/*========================================================================
                         Login/Registration styling
========================================================================*/
.index-login{
	flex: 1;
	flex-grow: 3;
	flex-basis: 30%;
	width: 10%;
	margin-right: 3%;
	margin-left: 1%;
	color: white;
	padding: 30px;
	text-align: left;
	background-color: #333;
	border-radius: 8px;
	border-style: solid;
	border-color: white;
	box-shadow: 0px 4px 6px rgba(0, 0, 0, 0.3);
	transition: transform 0.5s ease;
}

.login{
	position: absolute;
	top: 50%;
	left: 50%;
	transform: translate(-50%, -50%);
	width: 500px;
    color: white;
    padding: 30px;
    margin-bottom: 5px;
    text-align: left;
    background-color: #333;
    border-radius: 8px;
    border-style: solid;
    border-color: white;
	transition: transform 0.5s ease;
}

#register{
	text-decoration: none;
	font-weight: bold;
	text-align: center;
	color: white;
}

.index-container {
	display: flex;
	justify-content: space-between;
	align-items: flex-start;
	margin-left: 1%;
	margin-right: 1%;
}

  .trait {
    align-items: center;
    border-bottom: 1px solid #dadde1;
    display: flex;
    margin: 20px 16px;
    text-align: center;
}
  

/*========================================================================
                         MESSAGES 
========================================================================*/
#error-message-name, #error-message-port, #error-message-dbname {
    display: block;
    margin-top: 5px;
  }

.error {
	color: red; 
	font-weight: bold; 
	background-color: #ffe6e6;  
	padding: 10px; 
	margin-bottom: 10px;  
	border: 1px solid red;  
	border-radius: 5px; 
	text-align: center;
}

.success {
	color: green; 
	font-weight: bold; 
	background-color: #ffe6e6;  
	padding: 10px; 
	margin-bottom: 10px;  
	border: 1px solid green;  
	border-radius: 5px; 
	text-align: center;
}
EOF

##################
# Create the template file which contains the nav-bar and the footer
cat << 'EOF' > "$directory_name/template.pug"
html
  head
    meta(charset='UTF-8')
    title Site Generator
    <link rel="icon" type="image/png" href="img/favicon.png" />
    link(href='/template.css', rel='stylesheet', type='text/css')
    link(rel='stylesheet', href='https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css', integrity='sha512-iBBXm8fW90+nuLcSKlbmrPcLa0OT92xO1BIsZ+ywDWZCvqsWgccV3gFoRBv0z+8dLJgyAHIhR35VZc2oM/gI1w==', crossorigin='anonymous')
  body
    .navbar
      ul.ul-navbar
        li
          a#home-link.active-green(href='index')
            i.fas.fa-home
        if isAuthenticated
          li
            a#create-link(href='create') CREATE
          li
            a#edit-link(href='edit') EDIT
          li
            a#list-link(href='list') LIST
        if isAdmin
          li
            a#list-link(href='admin') ADMIN
        if isAuthenticated
          .right-float 
            li
              a#log-link(href='settings')
                i.fas.fa-cog
            li
              a#logout-link.active-red(href='/logout')
                i.fa.fa-sign-out-alt
    .container
      .row
        .col.text-center
            block title
      .row
        .col
          block content
      footer
        | &copy; Copyright 2023 - albi.grainca@uha.fr - batuhan.goker@uha.fr
EOF

###############
# Create the index.pug file
cat << 'EOF' > "$directory_name/index.pug"
extends template
block content
  img#welcome-logo(src='img/welcome.png')
  div.index-container
    #me
      img#inge-me(src='img/inge.png')
      p#welcome-title Welcome to the site!
      | The site is divided into several parts, and so that you do not get lost, we will accompany you: 
      br
      | - In the 
      span.texteBlue &quot;create&quot;
      |  section, you can create a website. 
      br
      | - In the 
      span.texteBlue &quot;edit&quot;
      |  section you can make all the necessary modifications to your creations (modifications on a site, etc) 
      br
      | - If you are a greedy tester who got lost in the list of created websites, the 
      span.texteBlue &quot;list&quot;
      |  section will allow you to find all your creations.
      div.trait
      | If you are a user 
      span.texteRed without rights
      |, you will not be able to 
      span.texteRed perform actions 
      | on the sites. Only an administrator or an authorized user has the 
      br
      | ability to stop, reactivate, delete or validate a site. However, you can absolutely create your own website and start it without authorization.
EOF

###########################
# Create the create.pug file (in which you can create sites)
cat << 'EOF' > "$directory_name/create.pug"
extends template
block title
  h1 Generate your site
block content
  div.form
    form(onsubmit='submitForm(event)', action='/createSite', method='POST')
      label(for='directory') Directory name:
      input#directory(type='text', name='directory', pattern='[A-Za-z0-9_-]+', placeholder="Example: my_new_site", onfocus="this.placeholder = ''", title="Special characters and spaces are not accepted", class='form-control', required)
      br
      label(for='name') Website name:
      input#name(type='text', name='name', placeholder="Example: my new site!", onfocus="this.placeholder = ''", title="Enter the desired site name", class='form-control', onblur='checkSiteNameAvailability(event)', required)
      span#error-message-name
      label(for='port') Port:
      input#port(type='text', name='port', pattern='^(?!3030)([0-9]|[1-9][0-9]{1,3}|[1-5][0-9]{4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5])$',  placeholder="Example: 2030", onfocus="this.placeholder = ''", title="Enter the desired site port", class='form-control', onblur='checkPortAvailability(event)', required)
      span#error-message-port
      label(for='dbname') Database name:
      input#dbname(type='text', name='dbname', pattern='[A-Za-z0-9_-]+', placeholder="Example: my_db_name", onfocus="this.placeholder = ''", title="Special characters and spaces are not accepted", class='form-control', onblur='checkDatabaseNameAvailability(event)', required)
      span#error-message-dbname
      br
      div.center
        button#button-submit(type='submit') Create

      script. 
        function submitForm(event) {
          event.preventDefault();

          const portInput = document.querySelector('#port');
          const nameInput = document.querySelector('#name');
          const dbnameInput = document.querySelector('#dbname');

          // Check if port and name are valid
          const portValid = portInput.style.borderColor !== 'red';
          const nameValid = nameInput.style.borderColor !== 'red';
          const dbnameValid = dbnameInput.style.borderColor !== 'red';

          if (portValid && nameValid && dbnameValid) {
            alert('Wait a few seconds, your site is being created. This operation may take several seconds.');
            event.target.submit();
          } else {
            alert('Please correct the errors in the form before submitting.');
          }
        }

        async function checkSiteNameAvailability(event) {
          const nameInput = event.target;
          const name = nameInput.value;
          const errorMessageSpan = document.querySelector('#error-message-name');

          if (name) {
            try {
              const response = await fetch(`/isSiteNameUsed/${encodeURIComponent(name)}`);
              const data = await response.json();

              if (data.nameUsed) {
                nameInput.style.borderColor = 'red';
                errorMessageSpan.textContent = 'Site name already used';
                errorMessageSpan.style.color = 'red';
              } else {
                nameInput.style.borderColor = 'green';
                errorMessageSpan.textContent = '';
              }
            } catch (error) {
              console.error('Error checking site name availability:', error);
            }
          }
        }

        async function checkPortAvailability(event) {
          const portInput = event.target;
          const port = portInput.value;
          const errorMessageSpan = document.querySelector('#error-message-port');

          if (port) {
            try {
              const response = await fetch(`/isPortUsed/${encodeURIComponent(port)}`);
              const data = await response.json();

              if (data.portUsed) {
                portInput.style.borderColor = 'red';
                errorMessageSpan.textContent = 'Port already used';
                errorMessageSpan.style.color = 'red';
              } else {
                portInput.style.borderColor = 'green';
                errorMessageSpan.textContent = '';
              }
            } catch (error) {
              console.error('Error checking port availability:', error);
            }
          }
        }

        async function checkDatabaseNameAvailability(event){
          const dbnameInput = event.target;
          const dbname = dbnameInput.value;
          const errorMessageSpan = document.querySelector('#error-message-dbname');

          if (dbname) {
            try {
              const response = await fetch(`/isDbNameUsed/${encodeURIComponent(dbname)}`);
              const data = await response.json();

              if (data.dbnameUsed) {
                dbnameInput.style.borderColor = 'red';
                errorMessageSpan.textContent = 'Database name already used';
                errorMessageSpan.style.color = 'red';
              } else {
                dbnameInput.style.borderColor = 'green';
                errorMessageSpan.textContent = '';
              }
            } catch (error) {
              console.error('Error checking dbname availability:', error);
            }
          }
        }
EOF

################
# Create the edit.pug file ( in which you can modify your site parameters)
cat << 'EOF' > "$directory_name/edit.pug"
extends template
block title
  h1 Edit your site
block content
  if noSites
    p No sites available.
  else
    div.form
      form(onsubmit='submitForm(event)', action='/updateSite', method='POST')
        label(for="site") Site:
        select(name='site', id='site', onchange='updateSiteId()')
          each site in sites
            option(value=site._id) #{site.name}
        input(type='hidden', name='id', id='id', value=sites[0]._id)
        br
        label(for="name") New Name:
        input(type='text', name='name', id='name', placeholder="Example: my new site!", onfocus="this.placeholder = ''", onblur='checkSiteNameAvailability(event)', required)
        span#error-message-name
        label(for="port") New Port:
        input(type='text', name='port', id='port', pattern='^([0-9]|[1-9][0-9]{1,3}|[1-5][0-9]{4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5])$',  placeholder="Example: 2030", onfocus="this.placeholder = ''", onblur='checkPortAvailability(event)', required)
        span#error-message-port
        input(type='submit', value='Update Site')

        script.
          function updateSiteId() {
            const siteSelect = document.getElementById('site');
            const idInput = document.getElementById('id');
            idInput.value = siteSelect.value;
          }

        script. 
          function submitForm(event) {
            event.preventDefault();

            const portInput = document.querySelector('#port');
            const nameInput = document.querySelector('#name');

            // Check if port and name are valid
            const portValid = portInput.style.borderColor !== 'red';
            const nameValid = nameInput.style.borderColor !== 'red';

            if (portValid && nameValid) {
              alert('Your website has been successfully updated!');
              event.target.submit();
            } else {
              alert('Please correct the errors in the form before submitting.');
            }
          }

          async function checkSiteNameAvailability(event) {
            const nameInput = event.target;
            const name = nameInput.value;
            const errorMessageSpan = document.querySelector('#error-message-name');

            if (name) {
              try {
                const response = await fetch(`/isSiteNameUsed/${encodeURIComponent(name)}`);
                const data = await response.json();

                if (data.nameUsed) {
                  nameInput.style.borderColor = 'red';
                  errorMessageSpan.textContent = 'Site name already used';
                  errorMessageSpan.style.color = 'red';
                } else {
                  nameInput.style.borderColor = 'green';
                  errorMessageSpan.textContent = '';
                }
              } catch (error) {
                console.error('Error checking site name availability:', error);
              }
            }
          }

          async function checkPortAvailability(event) {
            const portInput = event.target;
            const port = portInput.value;
            const errorMessageSpan = document.querySelector('#error-message-port');

            if (port) {
              try {
                const response = await fetch(`/isPortUsed/${encodeURIComponent(port)}`);
                const data = await response.json();

                if (data.portUsed) {
                  portInput.style.borderColor = 'red';
                  errorMessageSpan.textContent = 'Port already used';
                  errorMessageSpan.style.color = 'red';
                } else {
                  portInput.style.borderColor = 'green';
                  errorMessageSpan.textContent = '';
                }
              } catch (error) {
                console.error('Error checking port availability:', error);
              }
            }
          }
EOF

##################
# Create the list.pug file ( list of created sites)
cat << 'EOF' > "$directory_name/list.pug"
extends template
block title 
  h1 List of created sites
block content
  table.tableau-style
    thead
      tr
        th(onclick="sortTable(0)") Name of websites &#9650;&#9660;
        th(onclick="sortTable(1)") Name of databases &#9650;&#9660;
        th(onclick="sortTable(2)") Port &#9650;&#9660;
        th(onclick="sortTable(3)") Status &#9650;&#9660;
        th.center Actions
        script.
          function sortTable(n) {
            let table, rows, switching, i, x, y, shouldSwitch, dir, switchcount = 0;
            table = document.querySelector(".tableau-style");
            switching = true;
            dir = "asc";
              
            while (switching) {
              switching = false;
              rows = table.rows;
              for (i = 1; i < (rows.length - 1); i++) {
                shouldSwitch = false;
                x = rows[i].getElementsByTagName("TD")[n];
                y = rows[i + 1].getElementsByTagName("TD")[n];
                if (dir == "asc") {
                  if (x.innerHTML.toLowerCase() > y.innerHTML.toLowerCase()) {
                    shouldSwitch = true;
                    break;
                  }
                } else if (dir == "desc") {
                  if (x.innerHTML.toLowerCase() < y.innerHTML.toLowerCase()) {
                    shouldSwitch = true;
                    break;
                  }
                }
              }
              if (shouldSwitch) {
                rows[i].parentNode.insertBefore(rows[i + 1], rows[i]);
                switching = true;
                switchcount++;
              } else {
                if (switchcount == 0 && dir == "asc") {
                  dir = "desc";
                  switching = true;
                }
              }
            }
          }
    tbody
      each site in sites
        tr(id=`site-${site._id}`)
          td= site.name
          td= site.dbname
          td= site.port
          td 
            span.netstat(id=`status-${site._id}`)= site.status
          td
            form.form-inline(action='/deleteSite', method='post')
              input(type='hidden', name='id', value=site._id)
              button.button-style-red(type='submit', onclick='return confirmDelete()', disabled=!isAdmin) Delete
            form.form-inline(action='/stopSite', method='post')
              input(type='hidden', name='id', value=site._id)
              button.button-style-yellow(type='submit', onclick='return confirmStop()', disabled=!isAdmin) Stop
            form.form-inline(action='/startSite', method='post')
              input(type='hidden', name='id', value=site._id)
              button#button-submit(type='submit', onclick='return confirmStart()', disabled=!isAdmin) Start
            form.form-inline(action='/deploySite', method='post')
              input(type='hidden', name='id', value=site._id)
              button.button-style-blue(type='submit', onclick='return confirmDeploy()', disabled=!isAdmin) Deploy
      script.
        document.addEventListener('DOMContentLoaded', function() {
          const executions = document.querySelectorAll('span.netstat');
          console.log(executions.length);
          executions.forEach((execution) => {
            const status = execution.innerHTML;
            switch (status) {
              case "OFF":
                execution.style.color = '#FF0000';
                break;
              case "ON":
                execution.style.color = '#008000';
                break;
              default:
                execution.style.color = '#000000'; // default color if neither "Off" nor "On"
            }
          });
        });

        async function updateSiteStatus() {
          try {
            const response = await fetch('/siteStatus');
            const data = await response.json();

            data.forEach(site => {
              const siteStatusElement = document.querySelector(`#status-${site._id}`);
              siteStatusElement.textContent = site.status;

              switch (site.status) {
                case "OFF":
                  siteStatusElement.style.color = '#FF0000';
                  break;
                case "ON":
                  siteStatusElement.style.color = '#008000';
                  break;
                default:
                  siteStatusElement.style.color = '#000000'; // default color if neither "Off" nor "On"
              }
            });
          } catch (error) {
            console.error('Erreur lors de la récupération des statuts des sites:', error);
          }
        }

        const UPDATE_INTERVAL = 5000; // Temps en millisecondes, ici 5 secondes
        setInterval(updateSiteStatus, UPDATE_INTERVAL);
        
        function confirmDelete() {
          return confirm('Êtes-vous sûr de vouloir supprimer ce site ?');
        }

        function confirmStop() {
          return confirm('Êtes-vous sûr de vouloir arrêter ce site ?');
        }

        function confirmStart() {
          return confirm('Êtes-vous sûr de vouloir démarrer ce site ?');
        }

        function confirmDeploy() {
          return confirm('Êtes-vous sûr de vouloir déployer ce site ?');
        }
EOF

##########
# Create the admin.pug file
cat << 'EOF' > "$directory_name/admin.pug"
extends template
block title
  h1 Admin Page
block content
  br
  .tables-container
    .table-container
      h2 Unprove Users
      if unapprovedUsers.length === 0
        p The list is empty.
      else
        table.tableau-style
          thead
            tr 
              th Email
              th Status
              th Actions
          tbody
            each user in unapprovedUsers
              tr
                td= user.email
                td= user.status
                td
                  form.form-inline(action='/approveUser', method='post')
                    input(type='hidden', name='id', value=user._id)
                    button#button-submit(type='submit') Approve
                  form.form-inline(action='/deleteUser', method='post')
                    input(type='hidden', name='id', value=user._id)
                    button.button-style-red(type='submit') Delete
    .table-container
      h2 Approve Users
      if approvedUsers.length === 0
        p The list is empty.
      else
        table.tableau-style
          thead
            tr
              th Email
              th Status
              th Actions
          tbody
            each user in approvedUsers
              tr
              td= user.email
              td
                form.form-inline(action='/updateUser', method='post')
                  input(type='hidden', name='id', value=user._id)
                  select#status(name='status', onchange="this.form.submit()")
                    option(value='user', selected=user.status === 'user') User
                    option(value='admin', selected=user.status === 'admin') Admin
              td
                form.form-inline(action='/disapproveUser', method='post')
                  input(type='hidden', name='id', value=user._id)
                  button.button-style-yellow(type='submit') Disapprove
                form.form-inline(action='/deleteUser', method='post')
                  input(type='hidden', name='id', value=user._id)
                  button.button-style-red(type='submit') Delete
EOF

##############
# Create the settings.pug file ( in case the user wants to change his password)
cat << 'EOF' > "$directory_name/settings.pug"
extends template
block title
  h1 Settings
block content
  div.form
    h2.center Change your password:
    if errors
      each error in errors
        p.error= error.msg
    form(onsubmit='submitForm(event)', action='/updatePassword', method='POST')
        label(for='directory') Current password:
        input#current-password(type='password', name='current-password', placeholder="************", onfocus="this.placeholder = ''", title="Password", class='form-control' required)
        br
        label(for='name') New password:
        input#new-password(type='password', name='new-password', placeholder="************", onfocus="this.placeholder = ''", title="Password", class='form-control' required)
        label(for='dbname') Retype new password:
        input#confirm-password(type='password', name='confirm-password', placeholder="************", onfocus="this.placeholder = ''", title="Password", class='form-control' required)
        br
        div.center
          button#button-submit(type='submit') Change Password
EOF

###################
# Create the login.pug file
cat << 'EOF' > "$directory_name/login.pug"
extends template
block content
  img#welcome-logo(src='img/welcome.png')
  div.index-container
    #welcome-message
      img#inge(src='img/inge.png')
      p#welcome-title Welcome to the site!
      | The site is divided into several parts, and so that you do not get lost, we will accompany you: 
      br
      | - In the 
      span.texteBlue &quot;create&quot;
      |  section, you can create a website. 
      br
      | - In the 
      span.texteBlue &quot;edit&quot;
      |  section you can make all the necessary modifications to your creations (modifications on a site, etc) 
      br
      | - If you are a greedy tester who got lost in the list of created websites, the 
      span.texteBlue &quot;list&quot;
      |  section will allow you to find all your creations. 
      div.trait
      |  If you want to browse the site, you must first log in. If you are not registered on the site, you will have to register then wait for an administrator to 
      span.texteRed validate your registration request
      |.
      
    div.index-login
      if error
        p.error #{error}
      form(onsubmit='submitForm(event)', action='/login', method='POST')
        label(for='email') E-mail address:
        input#email(type='text', name='email', placeholder="Example: jack.roma@gmail.com", onfocus="this.placeholder = ''", title="E-mail address", class='form-control' required)
        br
        label(for='password') Password:
        input#password(type='password', name='password', placeholder="************", onfocus="this.placeholder = ''", title="Password", class='form-control' required)
        br
        div.center
          button.button-login(type='submit') LOG IN
        div.trait
        a.button-register(href="/signup") REGISTER
EOF

################
# Create the registration.pug file
cat << 'EOF' > "$directory_name/registration.pug"
extends template
block content
  .container
    .row
      .col.text-center
        block title
    .row
      .col
        block content
          div.login
            h1 Sign up
            // Bloc pour l'affichage des erreurs
            div#errors
              if errors
                each error in errors
                  p.error= error.msg
            form(onsubmit='submitForm(event)', action='/signup', method='POST')
              label(for='email') E-mail address:
              input#email(type='text', name='email', placeholder="Example: jack.roma@gmail.com", onfocus="this.placeholder = ''", title="E-mail address", class='form-control' required)
              br
              label(for='password') Password:
              input#password(type='password', name='password', placeholder="************", onfocus="this.placeholder = ''", title="Password", class='form-control' required)
              br
              label(for='confirm-password') Confirm Password:
              input#confirm-password(type='password', name='confirm-password', placeholder="************", onfocus="this.placeholder = ''", title="Confirm password", class='form-control' required)
              br
              div.center
                button.button-register(type='submit') SIGN UP
              div.trait
              p.center
              | Are you already registered? Log in
              a#register(href="/login")= " here "
              |!
EOF

############


# Give all permisions for this files

chmod -R a+rwx "$directory_name"

# Site generation server : server.js

cat << 'EOF' > "$directory_name/server.js"
const express = require('express');
const app = express();
const net = require('net');
const { exec } = require('child_process');
const bcrypt = require('bcryptjs');
const { body, validationResult } = require('express-validator');
const jwt = require('jsonwebtoken');
const cookieParser = require('cookie-parser');
require('dotenv').config();

// Set the root directory
const root = __dirname;
const port = 3030;

// Connect to the MongoDB database and create "sites" and "users" collections
const db = require('monk')('127.0.0.1:27017/mySites');
const sitesCollection = db.get('sites');
const usersCollection = db.get('users');

// Enable parsing of URL-encoded data in the request body
app.use(express.urlencoded({ extended: true }));

// Enable parsing of cookies
app.use(cookieParser());

// Set the view engine as Pug and specify the views directory
app.set('view engine', 'pug');
app.set('views', root);

// Serve static files from the root directory
app.use(express.static(root));

/***********  Middleware ***********/

// Checks if the user is logged into their account
const isAuth = async (req, res, next) => {
    // Check if the token exists in the request cookies
    if (req.cookies && req.cookies.token) {
        const token = req.cookies.token;
        // If no token is found, redirect to the login page
        if (!token) {
            return res.status(401).redirect('/login');
        }
        let decodedToken;
        try {
            // Verify the token using the secret key
            decodedToken = jwt.verify(token, `${process.env.SECRET_KEY}`);
        } catch (err) {
            // Handle token expiration error
            if (err instanceof jwt.TokenExpiredError) {
                // Clear the expired token cookie and redirect to the login page
                res.clearCookie('token');
                return res.status(401).redirect('/login');
            }
            // Handle other token verification errors
            err.statusCode = 500;
            throw err;
        }
        // If the token is valid but not decoded properly, throw an error
        if (!decodedToken) {
            const error = new Error('Not authenticated. Invalid token.');
            error.statusCode = 401;
            throw error;
        }
        // Retrieve the user from the database using the decoded user ID from the token
        const user = await usersCollection.findOne({ _id: decodedToken.userId });
        // Check if the token version in the user document matches the token version in the decoded token
        if (user.tokenVersion !== decodedToken.tokenVersion) {
            // Clear the token cookie and redirect to the login page
            res.clearCookie('token');
            return res.status(401).redirect('/login');
        }
        // Set additional properties on the request object
        req.userId = decodedToken.userId; // User ID from the token
        req.isAuthenticated = true; // Indicate that the user is authenticated
        req.isAdmin = decodedToken.status === 'admin'; // Check if the user is an admin
        // Proceed to the next middleware or route handler
        next();
    } else {
        // If no token exists in the request cookies, redirect to the login page
        res.redirect('/login');
    }
};

// Check if the user is an admin
const isAdmin = (req, res, next) => {
    // Retrieve the token from the request cookies
    const token = req.cookies.token;
    // If no token is found, send a 401 Unauthorized response
    if (!token) {
        return res.status(401).send('Access denied. Please log in.');
    }
    try {
        // Verify and decode the token using the secret key
        const decoded = jwt.verify(token, `${process.env.SECRET_KEY}`);
        // Assign the decoded token data to the req.user object
        req.user = decoded;
        // Check if the user status is 'admin'
        if (req.user.status !== 'admin') {
            // If not an admin, send a 403 Forbidden response and redirect to the /index page
            return res.status(403).redirect('/index');
        }
        // If the user is an admin, proceed to the next middleware or route handler
        next();
    } catch (err) {
        // If token verification or decoding fails, send a 401 Unauthorized response with an error message
        return res.status(401).send('Invalid token.');
    }
};


// Check if we have a token and return the user to index page if it is (this middleware allows to block the use of login and signup pages if the user is connected
const isNotAuth = (req, res, next) => {
	// Retrieve the token from the request cookies
    const token = req.cookies.token;
    if (token) {
        return res.redirect('/index');
    }
    next();
};

// Check the status of the user (logged in or not), as well as his rights to adapt the display of the nav-bar
const attachAuthInfo = (req, res, next) => {
	if (!req.isAuthenticated) {
		req.isAuthenticated = false;
		req.isAdmin = false;
	}
	next();
};
app.use(attachAuthInfo);

/*********** Routes ***********/ 

// Handle GET request for '/index' route
app.get('/index', isAuth, (req, res) => {
	res.render('index', { isAuthenticated: req.isAuthenticated, isAdmin: req.isAdmin });
});

// Handle GET request for '/' route and redirect to index
app.get('/', isAuth, (req, res) => {
	res.redirect('/index');
});

// Handle GET request to check if a port is used
app.get('/isPortUsed/:port', isAuth, async (req, res) => {
	try {
	  	const port = req.params.port;
	  	// Check if a site with the specified port exists in the database
	  	const portExists = await sitesCollection.findOne({ port });
	  	// Return a JSON response indicating whether the port is used or not
	  	res.json({ portUsed: !!portExists });
	} catch (err) {
	  	console.error('Error checking port availability:', err);
	  	// Return a 500 Internal Server Error response if an error occurs
	  	res.status(500).json({ portUsed: false });
	}
});
  
// Handle GET request to check if a site name is used
app.get('/isSiteNameUsed/:name', isAuth, async (req, res) => {
	try {
		const name = req.params.name;
	  	// Retrieve the site document with the specified name from the 'sitesCollection'
	  	const site = await sitesCollection.findOne({ name });
	  	// Return a JSON response indicating whether the site name is used or not
	  	res.json({ nameUsed: !!site });
	} catch (err) {
	  	console.error('Error checking site name availability:', err);
	  	// Return a 500 Internal Server Error response if an error occurs
	  	res.status(500).json({ nameUsed: false });
	}
});

// Handle GET request to check if a database name is used
app.get('/isDbNameUsed/:dbname', isAuth, async (req, res) => {
	try {
	  	const dbname = req.params.dbname;
	  	// Check if a site with the specified database name exists in the database
	  	const dbnameExists = await sitesCollection.findOne({ dbname });
	  	// Return a JSON response indicating whether the database name is used or not
	  	res.json({ dbnameUsed: !!dbnameExists });
	} catch (err) {
	  	console.error('Error checking database name availability:', err);
	  	// Return a 500 Internal Server Error response if an error occurs
	  	res.status(500).json({ dbnameUsed: false });
	}
});

// Handle GET request for '/login' route
app.get('/login', isNotAuth, (req, res) => {
	res.render('login', { isAuthenticated: req.isAuthenticated, isAdmin: req.isAdmin });
});

// Handle POST request for '/login' route
app.post('/login', isNotAuth, async(req, res) => {
	// Retrieve user-written email and password
	const email = req.body.email;
    const password = req.body.password;
	let loadedUser;
	try {
		// Find user with email
        const user = await usersCollection.findOne({ email: email});
        if (!user) {
			// Give an error if the user doesn't exist
            return res.render('login', { error: 'A user with this email could not be found.' });
        }
		if (!user.approved) {
			// Give error if the user is not approved by admin
			return res.render('login', { error: 'Your account is not approved yet. Please wait for admin approval.' });
		}
		// Compare the given password with the password in the db
        const isEqual = await bcrypt.compare(password, user.password);
        if(!isEqual) {
			// Give an error if the password is incorrect
            return res.render('login', { error: 'Invalid password.' });
        }
        loadedUser = user;
		// Generate a JSON Web Token (JWT)
        const token = jwt.sign({
				// Payload of the token, containing user-related data
                email: loadedUser.email,
                userId: loadedUser._id.toString(),
				tokenVersion: loadedUser.tokenVersion,
				status: loadedUser.status
            },
            `${process.env.SECRET_KEY}`, // Secret key used to sign the token
            { expiresIn: '1h' } // Token expiration time set to 1 hour
        );
		// Set a cookie named 'token' in the response
        res.cookie('token', token, { httpOnly: true, sameSite: 'strict' });
		// Redirect to "/index"
        res.redirect('/index');
    } catch (err) {
        if(!err.statusCode) err.statusCode = 500;
        return res.render('login', { error: 'An unexpected error occurred. Please try again.' });
    }
});

// Handle GET request for '/logout' route
app.get('/logout', (req, res) => {
	// Delete the cookie "token" to logout
	res.clearCookie('token');
	// Regirect to "/login"
	res.redirect('/login');
});

// Handle GET request for '/signup' route
app.get('/signup', isNotAuth, (req, res) => {
	// Render the 'registration' view
	res.render('registration');
});	

// Handle POST request for '/signup' route
app.post('/signup', isNotAuth,
	[
		// Validation and error handling middleware using express-validator
		body('email').isEmail()
		.withMessage('Please enter a valid email.')
		.custom(async (value, { req }) => {
			// Check if the email already exists in the users collection
			const userDoc = await usersCollection.findOne({ email: value });
			if (userDoc) {
				throw new Error('E-Mail address already exists!');
			}
		})
		.normalizeEmail(),
		body('password').trim().isLength({ min: 5 }).withMessage('Password must be at least 5 characters long.'),
		body('confirm-password').custom((value, { req }) => {
			// Check if the password confirmation matches the password
			if (value !== req.body.password) {
				throw new Error('Password confirmation does not match password');
			}
			return true;
		})
  	],
	async (req, res) => {
		try {
			// Get validation errors from the request
			const errors = validationResult(req);
			// Check if we have any errors
			if (!errors.isEmpty()) {
				// Map the error objects to a customized errorData array
				const errorData = errors.array().map(error => {
					return { type: 'field', value: error.value, msg: error.msg, path: error.param, location: 'body' };
				});
				// Render the 'registration' view with the error data
				return res.render('registration', { errors: errorData });
			}
			// Retrieve user-written email and password
			const email = req.body.email;
			const password = req.body.password;
			// Hash the password using bcrypt with a cost factor of 12
			const hashedPw = await bcrypt.hash(password, 12);
			// Create a new user object
			const newUser = {
				email: email,
				password: hashedPw,
				status: "user",
				approved: false,
				tokenVersion: 0
			};
			// Insert the user into db
			usersCollection.insert(newUser);
			// Regirect to "/login"
			res.redirect('/login');
		} catch (err) {
			if (!err.statusCode) err.statusCode = 500;
			return res.render('registration', { errors: [{ msg: 'An unexpected error occurred. Please try again.'}] });
		}
	}
);

// Handle GET request for '/create' route
app.get('/create', isAuth, (req, res) => {
	// Render the 'create' view
	res.render('create', { isAuthenticated: req.isAuthenticated, isAdmin: req.isAdmin });
});

// Handle POST request for '/createSite' route
app.post('/createSite', isAuth, (req,res) => {
	// Retrieve user-written directory, name of the web site, port number and db name
	var directory = req.body.directory;
	var name = req.body.name;
	var port = req.body.port;
	var dbname = req.body.dbname;
	// Run the script with the variables to create the site
	exec(root + '/script.sh ' + directory + ' ' + port + ' "' + name + '" ' + dbname);
	// Create a new site object
	const newSite = {
		directory: directory,
		name: name,
		port: port,
		dbname: dbname
	}
	// Insert the user into db
	sitesCollection.insert(newSite);
	// Regirect to "/list"
	res.redirect('/list');
});

// Handle GET request for '/list' route
app.get('/list', isAuth, async (req, res) => {
	try {
		// Retrieve all documents from the 'sitesCollection' collection
		const sites = await sitesCollection.find({});
	  	for (let site of sites) {
			// Check if the port used by the site is active
    		// Update the 'status' property accordingly
			site.status = (await isPortUsed(site.port)) ? 'ON' : 'OFF';
	  	}
		// Render the 'list' view
	  	res.render('list', { isAuthenticated: req.isAuthenticated, isAdmin: req.isAdmin, sites });
	} catch (err) {
	  	throw err;
	}
});

// Handle POST request for '/deleteSite' route
app.post('/deleteSite', isAuth, async (req, res) => {
	// Extract the value of 'id' from the request body
	const id = req.body.id;
	try {
		// Find the site by its ID in the sites collection	
		const site = await sitesCollection.findOne({ _id: id });
		const directory = site.directory;
		const portSite = site.port;
		const dbSiteName = site.dbname;
		// Execute a shell command to stop the site using the specified port
		exec(root + '/stop.sh ' + portSite);
		// Execute a shell command to delete the site directory
		exec(root + '/delete.sh ' + directory);
		// Remove the site db
		const MongoClient = require('mongodb').MongoClient;
		const mongoURL = 'mongodb://127.0.0.1:27017/' + dbSiteName;
		const client = new MongoClient(mongoURL, { useNewUrlParser: true, useUnifiedTopology: true });
		// Connect to the MongoDB server
		await client.connect();
		// Access the database
		const dbSite = client.db();
		// Drop the database associated with the site
		await dbSite.dropDatabase();
		// Close the database connection
		await client.close();
		// Remove the site from the sites collection
		await sitesCollection.remove({ _id: id });
		// Redirect to the 'list' page
		res.redirect('list');
	} catch (err) {
	  	console.error(err);
	}
});

// Handle POST request for '/stopSite' route
app.post('/stopSite', isAuth, async (req, res) => {
	// Extract the value of 'id' from the request body
	const id = req.body.id;
	try {
		// Find the site by its ID in the sites collection
		const site = await sitesCollection.findOne({ _id: id });
		const portSite = site.port;
		// Execute a shell command to stop the site using the specified port
		exec(root + '/stop.sh ' + portSite);
		// Delay the redirect to the 'list' page by 1 second
		setTimeout(function() {
			res.redirect('list');
		}, 1000);
	} catch (err) {
		console.log(err);
	}
});

// Handle POST request for '/startSite' route
app.post('/startSite', isAuth, async (req, res) => {
	// Extract the value of 'id' from the request body
	const id = req.body.id;
	try {
		// Find the site by its ID in the sites collection
		const site = await sitesCollection.findOne({ _id: id })
		const directory = site.directory;
		const portSite = site.port;
		// Execute a shell command to start the site using the specified directory and port
		exec(root + '/start.sh ' + directory + ' ' + portSite);
		// Delay the redirect to the 'list' page by 1 second
		setTimeout(function() {
			res.redirect('list');
		}, 1000);
	} catch (err) {
		console.log(err);
	}
});

const isPortUsed = (port) => {
	// Create a promise to handle the asynchronous operation
	return new Promise((resolve) => {
		// Create a server instance
		const server = net.createServer();
		// Event handler for the 'error' event
		server.once('error', (err) => {
			// If the error code indicates that the port is in use or access is denied,
			// resolve the promise with a value of true, indicating that the port is used
			if (err.code === 'EADDRINUSE' || err.code === 'EACCES') {
				resolve(true);
			} else {
				// For other error codes, resolve the promise with a value of false,
				// indicating that the port is not used
				resolve(false);
			}
		});
		// Event handler for the 'listening' event
		server.once('listening', () => {
			// Close the server immediately
			server.close();
			// Resolve the promise with a value of false, indicating that the port is not used
			resolve(false);
		});
		// Start the server by listening on the specified port and IP address
		server.listen(port, '127.0.0.1');
	});
};

// Handle GET request for '/siteStatus' route
app.get('/siteStatus', isAuth, async (req, res) => {
	try {
		// Retrieve all documents from the 'sitesCollection' collection
		const sites = await sitesCollection.find({});
		// Map each site to a promise that resolves to its status
	  	const statusPromises = sites.map(async (site) => {
			const status = await isPortUsed(site.port) ? 'ON' : 'OFF';
			return { _id: site._id, status };
	  	});
		// Resolve all status promises in parallel
	  	const statuses = await Promise.all(statusPromises);
	  	res.json(statuses);
	} catch (err) {
		res.status(500).json([]);
	}
});

// Handle GET request for '/edit' route
app.get('/edit', isAuth, async (req, res) => {
	try {
		// Retrieve all documents from the 'sitesCollection' collections
	  	const sites = await sitesCollection.find({});
		// Render the 'edit' view
	  	res.render('edit', { isAuthenticated: req.isAuthenticated, isAdmin: req.isAdmin, sites, noSites: sites.length === 0 });
	} catch (err) {
	  	throw err;
	}
}); 

// Handle POST request for '/updateSite' route
app.post('/updateSite', isAuth, async (req, res) => {
	// Extract values of 'id', 'name' and 'port' from the request body
	const id = req.body.id;
	const newName = req.body.name;
	const newPort = req.body.port;
	try {
		// Retrieve the site document with the specified id from the 'sitesCollection'
		const site = await sitesCollection.findOne({ _id: id });
		if (site) {
			const oldPort = site.port;
			const directory = site.directory;
			// Update site in the database
			await sitesCollection.update({ _id: id }, { $set: { name: newName, port: newPort } });
			// Update the site configuration with a shell script
			exec(root + '/update.sh ' + directory + ' ' + oldPort + ' ' + newPort + ' "' + newName + '"');
			setTimeout(() => { res.redirect('/list'); }, 1000);
		} else {
			res.status(404).send('Site not found');
		}
	} catch (err) {
		console.error(err);
		res.status(500).send('Server error');
	}
});

// Handle GET request for '/admin' route
app.get('/admin', isAuth, isAdmin, async (req, res) => {
  // Retrieve the token from the request cookies
	const token = req.cookies.token;
	// If no token is found, send a 401 Unauthorized response
	if (!token) return res.status(401).send('Access denied. Please log in.');
	try {
    // Verify the token using the secret key
		const decoded = jwt.verify(token, `${process.env.SECRET_KEY}`);
		// Get userIf from the token
		const userId = decoded.userId;
		// Retrieve all documents from the 'usersCollection' collection
		const users = await usersCollection.find({});
		// Separation of approved and unapproved users in two different tables
		const unapprovedUsers = [];
		const approvedUsers = [];
		for (let user of users) {
      if (user._id == userId)
				continue;
			if (user.approved == false)
				unapprovedUsers.push(user);
			if (user.approved == true)
				approvedUsers.push(user);
		}
		// Render the 'admin' view
	  	res.render('admin', { isAuthenticated: req.isAuthenticated, isAdmin: req.isAdmin, unapprovedUsers, approvedUsers });
	} catch (err) {
	  	throw err;
	}
});

// Handle POST request for '/approveUser' route
app.post('/approveUser', isAuth, isAdmin, async (req, res) => {
	const userId = req.body.id;
	try {
		// Update the user with the specified ID to set 'approved' to true
		const user = await usersCollection.update({ _id: userId }, { $set: { approved: true } });
		// If no user is found with the given ID, send a 404 Not Found response
		if (!user) return res.status(404).send('User not found.');
		// Redirect to '/admin' page if all is good
		res.redirect('/admin');
	} catch (err) {
	  	throw err;
	}
});

// Handle POST request for '/disapproveUser' route
app.post('/disapproveUser', isAuth, isAdmin, async (req, res) => {
	// Extract the value of 'id' from the request body
	const userId = req.body.id;
	try {
		// Update the user with the specified ID to set 'approved' to false
		const user = await usersCollection.update({ _id: userId }, { $set: { approved: false } });
		// If no user is found with the given ID, send a 404 Not Found response
		if (!user) return res.status(404).send('User not found.');
		// Redirect to '/admin' page if all is good
		res.redirect('/admin');
	} catch (err) {
	  	throw err;
	}
});

// Handle POST request for '/updateUser' route
app.post('/updateUser', isAuth, isAdmin, async (req, res) => {
	// Extract values of 'id' and 'status' from the request body
	const userId = req.body.id;
	const newStatus = req.body.status;
	try {
		// Update the user with the specified ID to set 'status' the new status
		const user = await usersCollection.update({ _id: userId }, { $set: { status: newStatus } });
		// If no user is found with the given ID, send a 404 Not Found response
		if (!user) return res.status(404).send('User not found.');
		// Redirect to '/admin' page if all is good
		res.redirect('/admin');
	} catch(err) {
	  	throw err;
	}
});

// Handle POST request for '/deleteUser' route
app.post('/deleteUser', isAuth, isAdmin, async (req, res) => {
	// Extract the value of 'id' from the request body
	const userId = req.body.id;
	try {
		// Delete the user with the specified ID
		const user = await usersCollection.remove({ _id: userId });
		if (!user) return res.status(404).send('User not found.');
		res.redirect('/admin');
	} catch(err) {
	  	throw err;
	}
});

// Handle GET request for '/settings' route
app.get('/settings', isAuth, async (req, res) => {
	// Render the 'settings' view
  	res.render('settings', { isAuthenticated: req.isAuthenticated, isAdmin: req.isAdmin });
});

// Handle POST request for '/updatePassword' route
app.post('/updatePassword', isAuth,
	[
		body('new-password').trim().isLength({ min: 5 }).withMessage('Password must be at least 5 characters long.'),
		body('confirm-password').custom((value, { req }) => {
			// Check if the password confirmation matches the password
			if (value !== req.body['new-password']) {
			  throw new Error('Password confirmation does not match password');
			}
			return true;
		})
	], 
	async (req, res) => {
		// Get validation errors from the request
		const errors = validationResult(req);
		// Check if we have any errors
		if (!errors.isEmpty()) {
			// Map the error objects to a customized errorData array
			const errorData = errors.array().map(error => {
				return { type: 'field', value: error.value, msg: error.msg, path: error.param, location: 'body' };
		  	});
			// Render the 'settings' view with the error data
		  	return res.render('settings', { errors: errorData });
		}
		// Retrieve the token from the request cookies
		const token = req.cookies.token;
		// Retrieve user-written curren-password and new-password
		const currentPassword = req.body['current-password'];
		const newPassword = req.body['new-password'];
		// If no token is found, send a 401 Unauthorized response
		if (!token) return res.status(401).send('Access denied. Please log in.');
		try {
			// Verify the token using the secret key
			const decoded = jwt.verify(token, `${process.env.SECRET_KEY}`);
			// Get userIf from the token
			const userId = decoded.userId;
			// Retrieve the user document with the specified id from the 'usersCollection'
			const user = await usersCollection.findOne({ _id: userId });
			// If no user is found with the given ID, send a 404 Not Found response
			if (!user) return res.status(404).send('User not found.');
			// Compare the given current-password with the password in the db
			const isEqual = await bcrypt.compare(currentPassword, user.password);
			// Give an error if the password is incorrect
        	if(!isEqual) return res.render('settings', { errors: [{ msg: 'Invalid current password.' }] });
			// Hash the neww password using bcrypt with a cost factor of 12
			const hashedPw = await bcrypt.hash(newPassword, 12);
			// Update the user with the specified ID to set 'password' the new password and to increment the tokenVersion
			const update = await usersCollection.update({ _id: userId }, { $set: { password: hashedPw, tokenVersion: user.tokenVersion + 1 } });
			// If no user is found with the given ID, send a 404 Not Found response
			if (!update) return res.status(404).send('Error update.');
			res.redirect('/login');
		} catch(err) {
			throw err;
		}
	}
);

/*********** Server ***********/

app.listen(port, () => {
	console.log(`Server listening at http://localhost:${port}`);
});
EOF

cat << 'EOF' > "$directory_name/createAdmin.js"
const bcrypt = require('bcryptjs');
const db = require('monk')('127.0.0.1:27017/mySites');
const usersCollection = db.get('users');

const createAdminAccount = async () => {
    try {
        // Check if the admin account already exists
        const adminDoc = await usersCollection.findOne({ status: 'admin' });
        if (adminDoc) {
            console.log('The administrator account already exists.');
            return;
        }
        // Ask for the login information for the administrator account
        const adminEmail = 'admin@example.com';
        const adminPassword = 'adminPassword';
        // Hash the password
        const hashedAdminPw = await bcrypt.hash(adminPassword, 12);
        // Create the admin account
        const adminUser = {
            email: adminEmail,
            password: hashedAdminPw,
            status: 'admin',
            approved: true, // Assuming the admin account is approved by default
            tokenVersion: 0,
        };  
        // Insert the admin account into the users collection
        await usersCollection.insert(adminUser);
        console.log('The administrator account has been successfully created.');
    } catch (err) {
        console.error('An error occurred while creating the administrator account:', err);
    } finally {
        // Close the database connection
        db.close();
    }
}

// Call the function to create the administrator account
createAdminAccount();
EOF

# Move the folder img to "TheGenerator" folder
chmod -R a+rwx img
mv img $directory_name

# Confirm the creation of the folders
echo "Site generated in the folder $directory_name."

# Create admin user if is not create
node "$directory_name"/createAdmin.js

# Launch the service
cd "$directory_name"/
node server.js &
sleep 2
firefox http://localhost:3030/