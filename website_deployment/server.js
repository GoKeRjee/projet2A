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
app.post('/deleteSite', isAuth, (req, res) => {
	// Extract the value of 'id' from the request body
	const id = req.body.id;
	// Find the site by its ID in the sites collection
	sitesCollection.findOne({ _id: id })
		.then((site) => {
			const directory = site.directory;
			const portSite = site.port;
			// Execute a shell command to stop the site using the specified port
			exec(root + '/stop.sh ' + portSite);
			// Execute a shell command to delete the site directory
			exec(root + '/delete.sh ' + directory);
			// Remove the site from the sites collection
			sitesCollection.remove({ _id: id }, function (err) {
				if (err) throw err;
				res.redirect('list');
			});
		})
		.catch((err) => {
			console.log(err);
		});
});

// Handle POST request for '/stopSite' route
app.post('/stopSite', isAuth, (req, res) => {
	// Extract the value of 'id' from the request body
	const id = req.body.id;
	// Find the site by its ID in the sites collection
	sitesCollection.findOne({ _id: id })
		.then((site) => {
			const portSite = site.port;
			// Execute a shell command to stop the site using the specified port
			exec(root + '/stop.sh ' + portSite);
			// Delay the redirect to the 'list' page by 1 second
			setTimeout(function() {
				res.redirect('list');
			}, 1000);
		})
		.catch((err) => {
			console.log(err);
		});
});

// Handle POST request for '/startSite' route
app.post('/startSite', isAuth, (req, res) => {
	// Extract the value of 'id' from the request body
	const id = req.body.id;
	// Find the site by its ID in the sites collection
	sitesCollection.findOne({ _id: id })
		.then((site) => {
			const directory = site.directory;
			const portSite = site.port;
			// Execute a shell command to start the site using the specified directory and port
			exec(root + '/start.sh ' + directory + ' ' + portSite);
			// Delay the redirect to the 'list' page by 1 second
			setTimeout(function() {
				res.redirect('list');
			}, 1000);
		})
		.catch((err) => {
			console.log(err);
		});
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
	try {
		// Retrieve all documents from the 'usersCollection' collection
		const users = await usersCollection.find({});
		// Separation of approved and unapproved users in two different tables
		const unapprovedUsers = [];
		const approvedUsers = [];
		for (let user of users) {
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