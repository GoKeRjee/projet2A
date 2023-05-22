# README - Installation and Deployment Guide

This README provides instructions for installing and deploying the website. It also includes information on how to navigate and use the different pages of the site.

## Installation

### Installation Steps

1. Inside the downloaded zip folder, you will find a bash script named "installer.sh". Initially, there is no need for any installation or configuration. Simply run this script, and it will handle the installations for you. Follow these steps:
   - Navigate to the directory where the script is located (the script will create the project folder in the current directory, so make sure the script is in the desired directory).
   - Open a terminal.
   - Enter the command: ```chmod -R a+rwx installer.sh```.
   - Enter the command: ```./installer.sh```.

   If you follow these steps correctly, the installations will begin. Please be patient as the process may take a few minutes. Make sure you are connected to the internet, as the script will install required modules.

   The script is configured to automatically launch the site once the installations are complete. By default, the site will open in Google, so if Google is not installed on your machine, the site may not display. In that case, don't worry. Simply open your preferred browser and enter the following link:
   - [http://localhost:3030/](http://localhost:3030/)

2. Once you are on the site, an admin account is automatically created for you. It is your responsibility to log in with these credentials and change the password to a different one.
   - Email: ```admin@example.com```
   - Password: ```adminPassword```

   Alternatively, you can create your own account and then log in with the default account to give yourself full rights over the created account. However, remember to delete the default account after use!

### Restarting the Site

If, for any reason, your machine shuts down or the site becomes inaccessible, you can restart the service by entering the following commands in the terminal (make sure you are in the project directory):
- ```sudo systemctl start mongod```
- ```node server.js```

### Troubleshooting

If your site is not working and you are unsure why, here are some useful instructions:

- If the MongoDB service is not running, it may explain why you are unable to connect to the site or access certain pages. You can check the status of the service using the command: `sudo systemctl status mongod`. If it is not active, start the service using the command: ```sudo systemctl start mongod```.

## User Documentation

Once you reach the index page, you will receive a message guiding you through the site navigation. For further information, here are some important details to effectively use the site:

### Admin Page

This page is only visible to users with administrator rights. It serves as a user management page where you will find two lists:
- List of users who have registered and are awaiting approval (actions: approve or delete the request).
- List of approved users (with actions such as disapproving the user or changing their rights on

 the site).

### Create Page

This page is exclusively dedicated to site creation.

There is a form to provide the site information:
- Site directory
- Site title
- Desired port
- Database name

Note that if the desired port or site name is already in use, the site will notify you, and you will need to choose a different port/site name. Also, make sure to read the instructions for creation carefully. For example, special characters and empty spaces are not allowed in the "directory name" field.

After clicking the "create" button, a confirmation message will appear, and the site will be created within 15 seconds. You can then check the status of the site (ON or OFF).

### Edit Page

This edit page allows authorized users to make modifications to previously created sites.

### List Page

On this page, you will find a list of the created sites. The page is designed to display essential information and provide options to pause, relaunch, or delete the site. Currently, a single click performs the actions associated with the buttons. If you are concerned about making a wrong action, don't worry. A message "Are you sure you want to delete site XXX?" is implemented to prevent accidental clicks. Additionally, you can deploy the site with a single click.

Note: If you do not have specific rights for the site, you can only view the list of sites. The actions mentioned are only available to users with appropriate rights.

### Settings Page

If a user wishes to change their password, they can visit the settings page, which allows them to modify their password.

You will also find login and registration pages that do not require specific instructions. However, note that a newly registered user cannot log in until an administrator approves the registration. This helps prevent malicious registrations or unwanted visitors.
