# CinemaWiki

## Home Page
- Description of the wiki
- Number of words/characters/line (general across most pages)

## Edit Page
- User input form
- Only for home page
- Admin only access

## Create Page
- User input form
- Writes content to a text file
- User needs to be logged in
- Displayed in the articles page
- Stores username and timestamp
- Stores any links to images, videos or other media

## About Page
- General information about the wiki
- Cannot be edited

## Admin Panel
- Only accessible to admins
- Display list of users
-- Able to edit and delete users
-- Able to create new users
- Display list of articles
-- Able to edit and delete articles

## Register/Login Page
- User must create unique username
- Stored in a database

## Articles Page
- Displays list of articles
-- Includes titles, user, review content and timestamp
-- Only original post and admin can edit/delete

# Tasks
- A single homepage containing authentic text details for anyone to view but not edit (Alexandra and Atanas)
- An up-to-date account on the number of words and characters displayed in the wiki text on the home page (Alexandra and Atanas)
- A link to a sign-in page which allos a user to register to edit the wiki (Darius, Reece and Stanislav)
- A log text file which is appended with user and date details each time a user attempts to log in (and out) of the wiki application (Darius, Reece and Stanislav)
- A link to a login page which allows only an administrator additional features to perform the following: (Darius, Reece and Stanislav)
-- Override/remove changes to the details made by a user
-- Archive the text to a separate backup file
-- Add/edit/delete user accounts and change their access privileges to edit or not edit the wiki text
-- Enable the wiki to be reset by the administrator to its initial defualt text
- A functional layout displaying the wiki features (???)
- Extra marks will be given for additional features such as stylish looks and feel (Alexandra and Atanas)

# How To Use Git
- git init (allows you to use git commands in that directory)
- git clone https://github.com/ReeceTait/CinemaWiki (clones the current state of the repo)(be sure to sign in to git)
- git pull origin master (gets the latest version of the repo)
- git status (displays the status of files)
- git add * (adds all files to be commited)
- git commit -m "<message>" (commits changes to local repo, <message> should be a commit comment)
- git push origin master (pushes local repo to the GitHub repo)
