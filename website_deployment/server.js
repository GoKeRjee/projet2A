const express = require('express');
const app = express();
const { exec } = require('child_process');
const root = __dirname;
app.use(express.static(root));
const port = 3030;

app.use(express.urlencoded({ extended: true })); // req.body
app.set('view engine','pug');
app.set('views',root);


app.get('/', (req, res) => {
  res.render('generateSite');
});

app.post('/generateSite',(req,res)=>{
	var nom = req.body.nom;
	var port = req.body.port;
	exec(root + '/script.sh ' + nom + ' ' + port);
	res.redirect('/generate');
});

app.listen(port, () => {
  console.log(`Server listening at http://localhost:${port}`);
});
