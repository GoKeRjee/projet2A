const express = require('express');
const app = express();
const net = require('net');
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

app.get('/edit', async (req, res) => {
	try {
	  const sites = await sitesColletion.find({});
	  res.render('edit', { sites, noSites: sites.length === 0 });
	} catch (err) {
	  throw err;
	}
  });  

app.get('/list', async (req, res) => {
	try {
	  const sites = await sitesColletion.find({});
	  for (let site of sites) {
		site.status = await isPortUsed(site.port) ? 'ON' : 'OFF';
	  }
	  res.render('list', { sites });
	} catch (err) {
	  throw err;
	}
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
	const id = req.body.id;
	sitesColletion.findOne({_id: id})
    .then((site) => {
		const directory = site.directory;
		const portSite = site.port
		exec(root + '/stop.sh ' + portSite);
		exec(root + '/delete.sh ' + directory);
		sitesColletion.remove({ _id: id }, function(err) {
			if (err) throw err;
        	res.redirect('list');
      	});
    })
    .catch((err) => {
      console.log(err);
    });
});

app.post('/stopSite', (req, res)=> {
	const id = req.body.id;
	sitesColletion.findOne({_id: id})
    .then((site) => {
		const portSite = site.port;
		exec(root + '/stop.sh ' + portSite);
		setTimeout(function() {
			res.redirect('list');
		}, 1000);
    })
    .catch((err) => {
      console.log(err);
    });
});

app.post('/startSite', (req, res)=> {
	const id = req.body.id;
	sitesColletion.findOne({_id: id})
    .then((site) => {
		const directory = site.directory;
		const portSite = site.port;
		exec(root + '/start.sh ' + directory + ' ' + portSite);
		setTimeout(function() {
			res.redirect('list');
		}, 1000);
    })
    .catch((err) => {
      console.log(err);
    });
});

const isPortUsed = (port) => {
	return new Promise((resolve) => {
	  const server = net.createServer();
	  server.once('error', (err) => {
		if (err.code === 'EADDRINUSE') {
		  resolve(true);
		} else {
		  resolve(false);
		}
	  });
  
	  server.once('listening', () => {
		server.close();
		resolve(false);
	  });
  
	  server.listen(port, '127.0.0.1');
	});
};

app.post('/updateSite', async (req, res) => {
  const id = req.body.id;
  const newName = req.body.name;
  const newPort = req.body.port;

  try {
    const site = await sitesColletion.findOne({ _id: id });
    if (site) {
      const oldPort = site.port;
      const directory = site.directory;

      // Update site in the database
      await sitesColletion.update({ _id: id }, { $set: { name: newName, port: newPort } });

      // Update the site configuration
      exec(root + '/update.sh ' + directory + ' ' + oldPort + ' ' + newPort + ' "' + newName + '"');

      setTimeout(() => {
        res.redirect('/list');
      }, 1000);
    } else {
      res.status(404).send('Site not found');
    }
  } catch (err) {
    console.error(err);
    res.status(500).send('Server error');
  }
});
  
app.get('/', (req, res) => {
	res.redirect('/index');
});

app.listen(port, () => {
	console.log(`Server listening at http://localhost:${port}`);
});