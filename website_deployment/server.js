const express = require('express');
const app = express();
const { exec } = require('child_process');
const root = __dirname;
app.use(express.static(root));
const port = 3030;

app.use(express.urlencoded({ extended: true })); // req.body
app.set('view engine','pug');
app.set('views',root);

const db = require('monk')('127.0.0.1:27017/mySites');
const sitesColletion = db.get('sites');

app.get('/index', (req, res) => {
	res.render('index');
});

app.get('/create', (req, res) => {
	res.render('create');
});

app.get('/edit', (req, res) => {
	res.render('edit');
});

app.get('/list', (req, res) => {
	sitesColletion.find({}, function(err, sites) {
		if (err) throw err;
		res.render('list', { sites: sites })
	});
});

app.get('/login', (req, res) => {
	res.render('login');
});

app.get('/registration', (req, res) => {
	res.render('registration');
});

app.post('/createSite',(req,res)=>{
	var directory = req.body.directory;
	var name = req.body.name;
	var port = req.body.port;
	exec(root + '/script.sh ' + directory + ' ' + port + ' "' + name + '"');

	// save data on db
	const newSite = {
		directory: directory,
		name: name,
		port: port
	}
	sitesColletion.insert(newSite);

	res.redirect('/create');
});

app.post('/deleteSite', (req, res)=> {
	const name = req.body.name;
	sitesColletion.remove({ name: name }, function(err) {
		if (err) throw err;
		res.redirect('list');
	})
});

app.get('/', (req, res) => {
	res.redirect('/index');
});

app.listen(port, () => {
	console.log(`Server listening at http://localhost:${port}`);
});