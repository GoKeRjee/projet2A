# README (English)

## 1 - Installation and Deployment of the Site:

### 1.1 - Installation Steps
In the zip folder, you will find a bash script named "installer.sh". You don't need to do any installation or configuration at first. Simply run this script, which will handle the installations for you. To do this, follow these steps:
  - go to the directory where the script is located (the script will create the project folder in the current directory, so make sure the script is in the desired directory)
  - open a terminal
  - sudo systemctl start mongod
  - enter the command: ```chmod -R a+rwx installer.sh```
  - enter the command: ./installer.sh

If these steps are followed, the installations will begin. Wait a few minutes and make sure you are connected to the internet, as the script will install modules.

The script is configured so that once the installations are finished, a tab will open with the site. By default, the site launches in Google, so if Google is not installed on your machine, the site may not display. If this is the case, don't panic: launch your preferred browser and type in the following link:
  - http://localhost:3030/

### 1.2 - Restarting the Site in Case of Problems:

If for any reason your machine turns off or the site becomes inaccessible, you can restart the service by typing the following commands in the terminal (making sure you are in the project directory):
  - node server.js
  - sudo systemctl start mongod

### 1.3 - Troubleshooting:
If your site is not working and you don't know why, here are some helpful tips:

- If the MongoDB service is not running, this may explain why you cannot connect to the site or access certain pages. You can check the service status with the command: sudo systemctl status mongod
Start the service if it is not enabled with the command: sudo systemctl start mongod

## 2 - User Documentation:

Upon reaching the index, a message is sent to the user to guide them through site navigation. To go further, here are some important information for using the site properly:

### 2.1 - Create Page:

This page is exclusively dedicated to site creation.

There is a form to provide information about the site to create:

- site directory
- site title
- desired port
- database name
Please note that if the desired port or site name is already in use, the site will notify you, and you will have to consider another port/site name. Also, make sure to read the instructions for creation. For example, special characters and blank spaces are not accepted in the "directory name" field.
After clicking the create button, a confirmation message appears, and the site is created within the next 15 seconds. It is then possible to check the status of the site (ON or OFF).

### 2.2 - Edit Page
This edit page allows authorized users to make changes to one or more previously created sites.

### 2.3 - List Page
On this page, there is a list of the sites that have been created. This page is designed to provide only essential information and the ability to pause, restart, or delete the site. Currently, a simple click performs the actions related to the buttons. If you are afraid of making a mistake, don't worry: a message "Are you sure you want to delete site XXX" has been implemented to prevent accidental clicks.

You will also find the login and registration pages, which do not require specific instructions.
