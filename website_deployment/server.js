const express = require('express');
const app = express();
const { exec } = require('child_process');
const root = __dirname;
app.use(express.static(root));
const port = 3030;

app.use(express.urlencoded({ extended: true })); // req.body
app.set('view engine','pug');
app.set('views',root);

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
  res.render('list');
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
	res.redirect('/create');
});

app.get('/', (req, res) => {
	res.redirect('/index');
});

app.listen(port, () => {
  console.log(`Server listening at http://localhost:${port}`);
});