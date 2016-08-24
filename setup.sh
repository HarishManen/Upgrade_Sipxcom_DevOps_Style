#! /bin/bash

echo "To which version you want to upgrade?? ex:add just  16.04  "
read VERSION
echo "You will need wget to download localy latest repo. If you don't have it inslled on your management machine please install it.."
wget http://download.sipxcom.org/pub/sipXecs/$VERSION/sipxecs-$VERSION.0-centos.repo

#renaming to sipxcom.repo. This is the repo used by me on the VBox machines. You should replace the one that you have under /etc/yum.repos.d 
mv sipxecs-$VERSION.0-centos.repo sipxcom.repo

#running ansible-playbook that will upgrade your cluster

ansible-playbook upgrade_sipxcom.yml

