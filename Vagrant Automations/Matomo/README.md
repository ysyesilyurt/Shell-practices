# Automate Installation of Matomo
An automation for Matomo installations and configurations that created with Vagrant.

## What it does?
Goal is to install Matomo with all its dependencies. 

## How does it work?
You can use ```vagrant_up.sh``` script for initiating process, because it is used for starting the ```vagrant up``` process smoothly.
Similarly, ```vagrant_down.sh``` script can be used for teardown (destroy, halt and suspend) process. 
All other files are responsible for Vagrant VM's configuration and WordPress installation-configuration phases. 