**This is Marketplace**.  Requirements as yet to be determined.  

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

Once installed, you need to create vagrant VM.  In a shell:

```
$ cd vagrant
$ vagrant up
```

This will build your environment.  This VagrantFile only contains a single server
at the moment, which is named `marketplace_web`.  It uses local IP 192.168.33.20.

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
machine:

```
$ cd /usr/share/nginx/www/sites/sgmarketplace.com
$ composer install
```

Composer will download all the packages and require you to setup some configuration
options.  Once you setup these options, you can access [http://dev.sgmarketplace.com](http://dev.sgmarketplace.com).

### Default MySQL Options
* Driver: pdo_mysql
* Host: 127.0.0.1
* Port: 3306
* User: root
* Password: [empty]
* DB Name: marketplace

### Default Mailer Options
Use all the default options


