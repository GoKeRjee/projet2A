# README - English Translation

## 1 - Installation and Site Deployment:

### 1.1 - Installation Steps
Within the provided zip folder, you will find a bash script named "installer.sh" along with this README file. There is no initial installation or configuration required. You simply need to execute this script, which will handle the installations for you. To do this, follow these steps:
   - Navigate to the directory containing the script (the script will create the project folder in the current directory, so make sure the script is in the desired directory)
   - Open a terminal
   - Enter the command: ```chmod -R a+rwx installer.sh```
   - Enter the command: ```./installer.sh```

By following these few steps, the installations will begin. Please be patient for a few minutes and ensure you have an active internet connection, as the script will install several modules.

The script is configured to automatically launch a tab to display the site once installations are completed. By default, the site opens in Firefox, so if Firefox is not installed on your machine, the site may not display. If this is the case, do not worry: launch your preferred browser and type in the following link:
   - http://localhost:3030/

Once you are on the site, a default administrator account is created for you. It is your duty to login using these credentials and change the password to a different one.
   - Email: ```admin@example.com```
   - Password: ```adminPassword```

You also have the option to use this default account once only, i.e., you can create your own account then login with the default account to grant all rights to the account you have created. However, remember to delete the default account after use!

### 1.2 - Site Restart in Case of Issues:

If for any reason your machine turns off, or the site becomes inaccessible, you can restart the service by typing the following commands into the terminal (ensure you're in the project directory):
   - ```sudo systemctl start mongod```
   - ```node server.js```

### 1.3 - Troubleshooting:
If your site stops working and you don't know why, here are some useful guidelines:

- If the MongoDB service isn't running, this might explain why you can't connect to the site, or access certain pages. You can check the status of the service with the following command: ```sudo systemctl status mongod```
  Start the service if it's not active with the following command: ```sudo systemctl start mongod```

## 2 - User Documentation:

Once you reach the index page, a message is displayed to guide users in navigating the site. To go further, here are some important instructions for using the site effectively:

### 2.1 - Admin Page

This page will only be visible if you are a user with administrative rights. It's a user management page. Here you will find two lists:
- A list of users who have registered and are waiting to be approved (actions: approve or delete the request)
- A list of approved users (with possible actions like disapproving the user, or changing their site rights)

### 2.2 - Create Page:

This page is dedicated exclusively to site creation.

There is a form to provide the details of the site to be created:

- The site directory
- The site title
- The port you wish to use
- The database name
You should note that if the desired port or site name is already in use, the site will notify you and you will need to consider a different port/site name. Also, make sure to read the instructions for creating a site. For example, special characters and blank spaces are not accepted in the "directory name" field.
After clicking the "Create" button, a confirmation message appears,

 and the site is created within the following 15 seconds. It is then possible to check the site status (ON or OFF).
By default, port 3030 is used for the base site, so it cannot be used to create a site.

### 2.3 - Edit Page

The "Edit" page allows authorized users to make modifications to a previously created site or sites. You have the option to change either the name of your site or the port that allows access to the site.

### 2.4 - List Page

This page displays a list of sites that have been created. This page is designed to display only the essential information and allows you to pause the site, restart it, or delete it. Currently, a simple click performs the actions associated with the buttons. If you're worried about making a mistake, don't worry: a "Are you sure you want to delete site XXX?" message has been set up to avoid unintentional clicks. One final feature, which is to deploy the site, was considered, but unfortunately, we were not able to implement it, so this action is not possible.

Please note: if you do not have specific rights to the site, you will only be able to view the list of sites. The proposed actions are only valid for users with rights.

### 2.5 - Settings Page
If a user wishes to change their password, they can visit the "Settings" page which allows the user to change their password.

The login and registration pages do not require specific instructions. However, it should be noted that a newly registered user will not be able to login until an administrator has approved the registration. This prevents malicious users or simply undesirable visitors from registering.
