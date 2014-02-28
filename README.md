This is a Symfony2-based project which includes a VagrantFile for easily getting
a local development environment going.

# Setup

## Checking out code

Checkout this project wherever you would like.  This project does contain 
Git Submodules, so you will want to use the `--recursive` option when checking
it out.

If you forgot to check it out recursively, don't fret. We can fix it.  Just do
a `git submodule update --init` and it'll download and initialize the submodules.

## Building Dev Environment

You will need to have [VirtualBox](https://www.virtualbox.org/) and [Vagrant](http://vagrantup.com)
installed on your machine before continuing.  The latest versions will work fine.

### Install the Vagrant plugin(s)

To keep the VirtualBox Guest Additions package up to date you should install the vagrant-vbguest plugin. This can be done using the following command:
```
$ vagrant plugin install vagrant-vbguest
```

#### Additional plugin if you are using Windows

You should install the vagrant-winnfsd plugin for Vagrant. This can be done using the following command:
```
$ vagrant plugin install vagrant-winnfsd
```

## Launch the VM

Once Vagrant and VirtualBox are installed, you need to create vagrant VM.  In a shell:

```
$ cd vagrant
$ vagrant up
```

This will build your environment. It will take several minutes. This VagrantFile contains the following servers:

Vagrant Name:  `marketplace_web`
IP Address:  192.168.33.20
Contents:  Ubuntu OS, nginx webserver (port 80), MySQL, MongoDB

Vagrnat Name:  `marketplace_search`
IP Address:  192.168.33.21
Contents:  Ubuntu OS, ElasticSearch 1.0.1 (port 9200)

Each of these boxes can be brought up and down individually by specifying the name.  EX:  `vagrant up marketplace_web`


## Editing hosts file

You need to add an entry into the hosts file on the host machine.  For *nix based 
operating systems, this is `/etc/hosts`.  For Windows, it is at `c:\Windows\System32\drivers\etc`

Add the following entry:

```
192.168.33.20  dev.sgmarketplace.com
```

## Accessing Marketplace
From now you should be able to access Marketplace at 
[http://dev.sgmarketplace.com/](http://dev.sgmarketplace.com/). 

## Running Composer
You will need to SSH to the new machine you just built.  

```
$ vagrant ssh marketplace_web
```

On the machine, your project is located at `/usr/share/nginx/www/sites/sgmarketplace.com`.  On your
VM:

```
$ cd /usr/share/nginx/www/sites/sgmarketplace.com
$ composer install
```

_You may be asked for your **github** username and password during composer installation.  Please supply them (this is a
github limit to prevent spamming clone).  **This should be fixed with the current composer.json file**_

Composer will download all the packages and require you to setup some configuration
options.  Once you setup these options, you can access [http://dev.sgmarketplace.com](http://dev.sgmarketplace.com).

### Connecting to MySQL

During installation of Symfony, you will be asked to enter in credentials for MySQL.  Here are your defaults:

* Driver: pdo_mysql
* Host: 127.0.0.1
* Port: 3306
* User: root
* Password: [empty]
* DB Name: marketplace

Once configured, you may want to connect to MySQL on your local box via a third party tool.  For OSX, we recommend using
[Sequel Pro](http://www.sequelpro.com/).  For Windows, we recommend using [MySQL Workbench](http://www.mysql.com/products/workbench/).
To connect to the box, you will need to conenct via SSH to the machine.  Here are your defaults:

SSH Host:  192.168.33.20
SSH User:  vagrant
SSH Key: ~/.vagrant.d/insecure_private_key for OSX or %HOMEPATH%\.vagrant.d\insecure_private_key for Windows


### Connecting to MongoDB

[MongoDB](http://www.mongodb.org/) is running on port 27017 on the `marketplace_web` server at IP 192.168.33.20.  No
collections have been created by default.  There is no authentication required to connect to MongoDB currently.  If you
would like to connect and browse collections, you can use [Robomongo](http://robomongo.org/) for OSX, or
[MongoVUE](http://www.mongovue.com/) for Windows.

### Connecting to Elasticsearch

[Elasticsearch](http://www.elasticsearch.org/) is running on port 9200 of the `marketplace_search` server at IP 192.168.33.21.  By default, there are no
mappings created.  We have installed a few plugins for your use that you can access via your web browser.

[kopf](https://github.com/lmenezes/elasticsearch-kopf) - http://192.168.33.21:9200/_plugin/kopf
[BigDesk](http://bigdesk.org/) - http://192.168.33.21:9200/_plugin/bigdesk


### Default Mailer Options
Use all the default options


