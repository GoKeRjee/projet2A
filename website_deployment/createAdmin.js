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
