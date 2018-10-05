#!/bin/bash

# bash script for starting the vagrant up process
# needs to be executed inside vagrant machine's folder 
# with "sudo" priviliges

echo -n "Did you suspend or halt the machine? [y/n]:"
read machine_situation
if [[ "$machine_situation" == 'y' ]]; then
	echo "Starting inactive machine..."
	site=1 ip=2 vagrant up
else
	echo -n "How do you want to name the Matomo management site? (as '****.com'):"
	read site_to_install
	echo -n "Please enter the IP address that you are going to use for this site:"
	read ip_address
	echo "Initiating process..."
    sudo echo "$ip_address ${site_to_install}.com" >> /etc/hosts 
	site=$site_to_install ip=$ip_address vagrant up
fi