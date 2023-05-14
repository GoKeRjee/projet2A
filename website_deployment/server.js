const express = require('express');
const app = express();
const net = require('net');
const { exec } = require('child_process');
const bcrypt = require('bcryptjs');
const { body, validationResult } = require('express-validator');
const jwt = require('jsonwebtoken');
const cookieParser = require('cookie-parser');
require('dotenv').config();

const root = __dirname;
app.use(express.static(root));
const port = 3030;

app.use(express.urlencoded({ extended: true })); // req.body
app.use(cookieParser());
app.set('view engine','pug');
app.set('views',root);

const db = require('monk')('127.0.0.1:27017/mySites');
const sitesCollection = db.get('sites');
const usersCollection = db.get('users');

// Auth middleware
const isAuth = (req, res, next) => {
	if (req.cookies && req.cookies.token) {
		const token = req.cookies.token;
		if (!token) {
			return res.status(401).redirect('/login');
		}
		let decodedToken;
		try {
			decodedToken = jwt.verify(token, `${process.env.SECRET_KEY}`);
		} catch (err) {
			if (err instanceof jwt.TokenExpiredError) {
				res.clearCookie('token');
				return res.status(401).redirect('/login');
			}
			err.statusCode = 500;
			throw err;
		}
		if (!decodedToken) {
			const error = new Error('Not authenticated. Invalid token.');
			error.statusCode = 401;
			throw error;
		}
		req.userId = decodedToken.userId;
		next();
	} else {
		res.redirect('/login');
	}
};

const isAdmin = (req, res, next) => {
	const token = req.cookies.token;
    if (!token) {
        return res.status(401).send('Access denied. Please log in.');
    }
    try {
        const decoded = jwt.verify(token, `${process.env.SECRET_KEY}`);
        req.user = decoded;
        if (req.user.status !== 'admin') {
            return res.status(403).redirect('/index');
        }
        next();
    } catch (err) {
        return res.status(401).send('Invalid token.');
    }
};

const isNotAuth = (req, res, next) => {
    const token = req.cookies.token;
    if (token) {
        return res.redirect('/index');
    }
    next();
};

// Pages
app.get('/index', isAuth, (req, res) => {
	res.render('index');
});

app.get('/isPortUsed/:port', isAuth, async (req, res) => {
	const port = req.params.port;
	const portExists = await sitesCollection.findOne({ port });
	res.json({ portUsed: !!portExists });
});

app.get('/isSiteNameUsed/:name',isAuth, async (req, res) => {
	try {
		const name = req.params.name;
		const site = await sitesCollection.findOne({ name });
		res.json({ nameUsed: !!site });
	} catch (err) {
		console.error('Error checking site name availability:', err);
		res.status(500).json({ nameUsed: false });
	}
});

app.get('/isDbNameUsed/:dbname', isAuth, async (req, res) => {
	const dbname = req.params.dbname;
	const dbnameExists = await sitesCollection.findOne({ dbname });
	res.json({ dbnameUsed: !!dbnameExists });
});  

app.get('/create', isAuth, (req, res) => {
	res.render('create');
});

app.get('/edit', isAuth, async (req, res) => {
	try {
	  	const sites = await sitesCollection.find({});
	  	res.render('edit', { sites, noSites: sites.length === 0 });
	} catch (err) {
	  	throw err;
	}
});  

app.get('/list', isAuth, async (req, res) => {
	try {
		const sites = await sitesCollection.find({});
	  	for (let site of sites) {
			site.status = (await isPortUsed(site.port)) ? 'ON' : 'OFF';
	  	}
	  	res.render('list', { sites });
	} catch (err) {
	  	throw err;
	}
});

app.get('/login', isNotAuth, (req, res) => {
	res.render('login');
});

app.post('/login', isNotAuth, async(req, res) => {
	const email = req.body.email;
    const password = req.body.password;
	let loadedUser;
	try {
        const user = await usersCollection.findOne({ email: email});
        if (!user) {
            return res.render('login', { error: 'A user with this email could not be found.' });
        }
		if (!user.approved) {
			return res.render('login', { error: 'Your account is not approved yet. Please wait for admin approval.' });
		}
        const isEqual = await bcrypt.compare(password, user.password);
        if(!isEqual) {
            return res.render('login', { error: 'Invalid password.' });
        }
        loadedUser = user;
        const token = jwt.sign({
                email: loadedUser.email,
                userId: loadedUser._id.toString(),
				status: loadedUser.status
            },
            `${process.env.SECRET_KEY}`,
            { expiresIn: '1h' }
        );
        res.cookie('token', token, { httpOnly: true, sameSite: 'strict' });
        res.redirect('/index');
    } catch (err) {
        if(!err.statusCode) err.statusCode = 500;
        return res.render('login', { error: 'An unexpected error occurred. Please try again.' });
    }
});

app.get('/logout', (req, res) => {
	res.clearCookie('token');
	res.redirect('/login');
});


app.get('/signup', isNotAuth, (req, res) => {
	res.render('registration');
});	

app.post('/signup', isNotAuth,
  [
    body('email').isEmail()
      .withMessage('Please enter a valid email.')
      .custom(async (value, { req }) => {
        const userDoc = await usersCollection.findOne({ email: value });
        if (userDoc) {
          throw new Error('E-Mail address already exists!');
        }
      })
      .normalizeEmail(),
    body('password').trim().isLength({ min: 5 }).withMessage('Password must be at least 5 characters long.'),
	body('confirm-password').custom((value, { req }) => {
		if (value !== req.body.password) {
		  throw new Error('Password confirmation does not match password');
		}
		return true;
	  })
  ],
  async (req, res) => {
    try {
		const errors = validationResult(req);
		if (!errors.isEmpty()) {
			const errorData = errors.array().map(error => {
				return { type: 'field', value: error.value, msg: error.msg, path: error.param, location: 'body' };
		  	});
		  	return res.render('registration', { errors: errorData });
		}

      	const email = req.body.email;
      	const password = req.body.password;
      	const hashedPw = await bcrypt.hash(password, 12);
      	const newUser = {
			email: email,
        	password: hashedPw,
			status: "user",
			approved: false
      	};
      	usersCollection.insert(newUser);
      	res.redirect('/login');
    } catch (err) {
		if (!err.statusCode) err.statusCode = 500;
	  	return res.render('registration', { errors: 'An unexpected error occurred. Please try again.' });
    }
});

app.post('/createSite', isAuth,(req,res)=>{
	var directory = req.body.directory;
	var name = req.body.name;
	var port = req.body.port;
	var dbname = req.body.dbname;
	exec(root + '/script.sh ' + directory + ' ' + port + ' "' + name + '" ' + dbname);
	// save data on db
	const newSite = {
		directory: directory,
		name: name,
		port: port,
		dbname: dbname
	}
	sitesCollection.insert(newSite);
	res.redirect('/list');
});

app.post('/deleteSite', isAuth, (req, res)=> {
	const id = req.body.id;
	sitesCollection.findOne({_id: id})
    .then((site) => {
		const directory = site.directory;
		const portSite = site.port
		exec(root + '/stop.sh ' + portSite);
		exec(root + '/delete.sh ' + directory);
		sitesCollection.remove({ _id: id }, function(err) {
			if (err) throw err;
        	res.redirect('list');
      	});
    })
    .catch((err) => {
      console.log(err);
    });
});

app.post('/stopSite', isAuth, (req, res)=> {
	const id = req.body.id;
	sitesCollection.findOne({_id: id})
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

app.post('/startSite', isAuth, (req, res)=> {
	const id = req.body.id;
	sitesCollection.findOne({_id: id})
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
			if (err.code === 'EADDRINUSE' || err.code === 'EACCES') {
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

app.post('/updateSite', isAuth, async (req, res) => {
	const id = req.body.id;
	const newName = req.body.name;
	const newPort = req.body.port;

	try {
		const site = await sitesCollection.findOne({ _id: id });
		if (site) {
			const oldPort = site.port;
			const directory = site.directory;
			// Update site in the database
			await sitesCollection.update({ _id: id }, { $set: { name: newName, port: newPort } });
			// Update the site configuration
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
  
app.get('/', isAuth, (req, res) => {
	res.redirect('/index');
});

app.get('/siteStatus', isAuth, async (req, res) => {
	try {
		const sites = await sitesCollection.find({});
	  	const statusPromises = sites.map(async (site) => {
			const status = await isPortUsed(site.port) ? 'ON' : 'OFF';
			return { _id: site._id, status };
	  	});
	  	const statuses = await Promise.all(statusPromises);
	  	res.json(statuses);
	} catch (err) {
		res.status(500).json([]);
	}
});

app.listen(port, () => {
	console.log(`Server listening at http://localhost:${port}`);
});


app.get('/admin', isAuth, isAdmin, async (req, res) => {
	try {
		const users = await usersCollection.find({});
		const unproveUsers = [];
		const approvedUsers = [];
		for (let user of users) {
			if (user.approved == false)
				unproveUsers.push(user);
			if (user.approved == true)
				approvedUsers.push(user);
		}
	  	res.render('admin', { unproveUsers, approvedUsers });
	} catch (err) {
	  	throw err;
	}
});

app.post('/approveUser', isAuth, isAdmin, async (req, res) => {
	const id = req.body.id;
	try {
		const user = await usersCollection.update({ _id: id }, { $set: { approved: true } });
		if (!user) return res.status(404).send('User not found.');
		res.redirect('/admin');
	} catch (err) {
	  	throw err;
	}
});

app.post('/unproveUser', isAuth, isAdmin, async (req, res) => {
	const id = req.body.id;
	try {
		const user = await usersCollection.update({ _id: id }, { $set: { approved: false } });
		if (!user) return res.status(404).send('User not found.');
		res.redirect('/admin');
	} catch (err) {
	  	throw err;
	}
});

app.post('/updateUser', isAuth, isAdmin, async (req, res) => {
	const userId = req.body.id;
	const newStatus = req.body.status;
	try {
		const user = await usersCollection.update({ _id: userId }, { $set: { status: newStatus } });
		if (!user) return res.status(404).send('User not found.');
		res.redirect('/admin');
	} catch(err) {
	  	throw err;
	}
});