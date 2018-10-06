# WordPress with Servers
Automation for WordPress installations, configurations and migrations with some useful servers.

## What it does?
The goal is to migrate an existing WordPress project from a dedicated "test" server to a Vagrant Virtual Machine, using additional Jenkins and Gitlab servers.

## How does it work?
```vagrant_up``` is used for starting the ```vagrant up``` or ```vagrant provision``` process smoothly. ```vagrant_down``` is used to ease Vagrant machine's teardown (destroy, halt and suspend) process. ```Vagrantfile``` contains all the configuration that Vagrant Virtual Machine needs. ```Vagrantfile``` needs to get a ```vm.box``` that has Apache, MySQL and PHP installed beforehand. ```setup``` is the external bash script that provisions Vagrant machine on start-up. It first installs WordPress and then migrates the WordPress site from test server accordingly. It uses some dedicated Jenkins jobs from a Jenkins server to smooth the migration process. It also uses a Gitlab server to clone the project theme from its corresponding repositories. The other files are used during installation-configuration processes.

Since this is just a prototype for the goal, I set server names as ```blabla.com``` and for multi-site purposes I set main URL of Vagrant VM's web server as ```developer.blabla.com``` so that an user can install more than one WordPress projects under this URL using ```vagrant provision``` with an edited ```setup``` script. Note that I was using a Vagrant base box named ```centos7-vagrant-wp``` in which I installed Apache, MySQL and PHP beforehand. Thus a similar base box needs to be used for this process.