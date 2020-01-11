# Intro

This is a very simple, very dumb backup system for our websites that
I hacked together in about a day when the duplicator plugin stopped
working on our wordpress install.  I've been running it pseudo-regularly
for a few years.  It could use some cleanup, but I'm capturing it for
posterity.

You run it on a local linux system, you give it the right config
parameters and make sure your credentials are set up (passwordless
ssh login to the web hosting server, plus the database login info
stored in a [local file](example.conf) on your local machine, plus
the google drive credentials), and it'll rsync the files, store the
database, git commit to keep history, and upload the directory to
google drive, if all goes well.

# Setup

Install command-line drive:

 * <https://github.com/odeke-em/drive/blob/master/platform_packages.md>

Hopefully you have credentials already in drive-credentials.json
If not, you can get some at:

 * <https://console.developers.google.com>

(The Google Drive API is hopefully already enabled, else you'll have
to enable it.)

You'll hopefully already have a project, such as "website-backups",
else you'll have to create one.

Go to your project ("website-backups", for instance) and then
the "Credentials" page, and "Create credentials", with a service
account key. If you have to make a service account, give it
admin access to storage objects. Then download the json and use
that.

# Recovering

Pulling the previously-stored contents from google drive:

~~~
drive init ~/gdrive
cd ~/gdrive
drive pull website-backups
~~~

You'll then have to get the contents pushed to the web server in the
appropriate web root, and [import](https://dba.stackexchange.com/a/24372)
the sqldump.sql file into the database.

# Running backups

Capturing current contents of website and database, doing a git
commit to the local directories, and pushing them to google drive:

~~~
cd ~/gdrive && ./run.sh
~~~

