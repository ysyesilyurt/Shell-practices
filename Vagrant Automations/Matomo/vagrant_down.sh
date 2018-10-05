#!/bin/bash

# bash script for starting the vagrant teardown process
# needs to be executed inside vagrant machine's folder 
# with "sudo" priviliges

echo -n "Do you want to suspend, halt, or destroy the Vagrant machine? [s/h/d]:"
read choice

if [[ $choice == 's' ]]; then
	site=1 ip=2 vagrant suspend
elif [[ $choice == 'h' ]]; then
	site=1 ip=2 vagrant halt
else
	site=1 ip=2 vagrant destroy
fi