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
		meta(name='viewport', content='width=device-width, initial-scale=1')
		title <LOGO>
		link(href='https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css', rel='stylesheet')
		link(href='https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css', rel='stylesheet')
		link(href='/template.css', rel='stylesheet')
	body
		.container
			.row.text-center
				.col
					h1#title <HEADER>
			nav.navbar.navbar-expand-lg.navbar-light.bg-light
				.container-fluid
					button.navbar-toggler(type='button', data-bs-toggle='collapse', data-bs-target='#navbarNav', aria-controls='navbarNav', aria-expanded='false', aria-label='Toggle navigation')
						span.navbar-toggler-icon
					.collapse.navbar-collapse#navbarNav
						ul.navbar-nav.ml-auto.mx-auto
							li.nav-item
								a.nav-link(href='/page/index')
									i.fas.fa-home
									|  Home
							li.nav-item
								a.nav-link(href='/pages')
									i.fas.fa-list-ul
									|  List
							li.nav-item
								a.nav-link(href='/upload')
									i.fas.fa-cloud-upload-alt
									|  Upload
							li.nav-item
								a.nav-link(href='/files')
									i.fas.fa-folder-open
									|  Files
							li.nav-item
								a.nav-link(href='/config')
									i.fas.fa-cog
									|  Settings
			.row
				.col
					block content
			div#footer <FOOTER>

		script(src='https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.bundle.min.js')" > "$directory_name/tempalte"

# Creation of the template.pug file
echo "html
	head
		meta(charset='utf-8')
		meta(name='viewport', content='width=device-width, initial-scale=1')
		title $website_name
		link(href='https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css', rel='stylesheet')
		link(href='https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css', rel='stylesheet')
		link(href='/template.css', rel='stylesheet')
	body
		.container
			.row.text-center
				.col
					h1#title $website_name
			nav.navbar.navbar-expand-lg.navbar-light.bg-light
				.container-fluid
					button.navbar-toggler(type='button', data-bs-toggle='collapse', data-bs-target='#navbarNav', aria-controls='navbarNav', aria-expanded='false', aria-label='Toggle navigation')
						span.navbar-toggler-icon
					.collapse.navbar-collapse#navbarNav
						ul.navbar-nav.ml-auto.mx-auto
							li.nav-item
								a.nav-link(href='/page/index')
									i.fas.fa-home
									|  Home
							li.nav-item
								a.nav-link(href='/pages')
									i.fas.fa-list-ul
									|  List
							li.nav-item
								a.nav-link(href='/upload')
									i.fas.fa-cloud-upload-alt
									|  Upload
							li.nav-item
								a.nav-link(href='/files')
									i.fas.fa-folder-open
									|  Files
							li.nav-item
								a.nav-link(href='/config')
									i.fas.fa-cog
									|  Settings
			.row
				.col
					block content
			div#footer &copy; 2023 - albi.grainca@uha.fr - batuhan.goker@uha.fr

		script(src='https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.bundle.min.js')"> "$directory_name/template.pug"


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

# Create index page
echo "const db = require('monk')('127.0.0.1:27017/toto');
const pages = db.get('pages');

const createIndexPage = async () => {
  	try {
		// Check if the admin account already exists
		const indexDoc = await pages.findOne({ name: 'index' });
		if (indexDoc) {
			console.log('The page already exists.');
			return;
		}
    	const name = 'index';
    	const content = '# In ora Phaethon ab nisi sine ignem\n\n'
    		+ '## Facta vertebar nec artes\n\n'
      		+ 'Lorem markdownum. Alii ornum at ipse ab ferox fontis, ego membris victor\n'
     		+ 'dicimus, non. **Annua omnibus est** fetu tibi. Ferarum qui fera\n'
      		+ '[fontibus](http://turris-dixit.com/mox.php), in dabat sinunt quod opus iungere\n'
      		+ 'corpore. Sororem accessi Susurri **at superas** membra Iuppiter abit protinus,\n'
     		+ 'et.\n\n'
     		+ '## Verba quae qui non\n\n'
      		+ 'Nos virgo, graniferumque auro: suos mensae ferit aquilonibus misit coluit. Et\n'
      		+ 'lato toro habe, non colubris: Nereida, segnior. Supplex magno qua colla\n';

    	const newPage = {
      		name: name,
      		content: content
    	};
    	await pages.insert(newPage);
    	console.log('New page created successfully!');
  	} catch (err) {
    	console.error('An error occurred while creating the page:', err);
  	} finally {
    	db.close();
  	}
};

// Call the function to create a new page
createIndexPage();" > "$directory_name/createIndexPage.js"


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
	res.redirect('/page/index');
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

# Create the index page
node "$directory_name"/createIndexPage.js 

# Launch the service
node "$directory_name"/server.js &
sleep 2
google-chrome http://localhost:$port/
