# **Upgrading Sipxcom cluster in DevOps style using Ansible**

Ansible is a configuration management tool, one of the best available. This tool doesn’t need any clients installed on remote machines and uses ssh to execute remote commands on the servers that form the sipxcom cluster.

Normally, to upgrade a sipxcom cluster you need to download the latest sipxcom.repo on each of the servers. Then starting with secondaries you needed to update the system and then reload it.

With Ansible we can execute all of these steps from the management machine which is running Ansible. In this Proof of Concept (PoC) we are using a cluster created previously with vagrant/VirtualBox on a local machine.


Let’s get hands-on:

**Step 1. Copy ssh keys from your remote servers with ssh-copy-id command.**
 Replace the bellow IP’s with yours:

 ```
 [mihai@localhost SIPXCOM_Cluster]$ ssh-copy-id root@10.0.0.201
 [mihai@localhost SIPXCOM_Cluster]$ ssh-copy-id root@10.0.0.202
 [mihai@localhost SIPXCOM_Cluster]$ ssh-copy-id root@10.0.0.203
```

**Step 2. Create an inventory.ini file**

 - used by ansible to identify the managed hosts and an ansible.cfg file that will instruct ansible to read the inventory file created in local path

```
[mihai@localhost SIPXCOM_upgrade]$ cat ansible.cfg
[defaults]
hostfile = inventory.ini
remote_user = root
[mihai@localhost SIPXCOM_upgrade]$ cat inventory.ini
[uc1]
10.0.0.201
[secondaries]
10.0.0.202
10.0.0.203
```


**Step 3. Download the latest repo.**
When this blog article was written latest version was 16.04
```
[mihai@localhostSIPXCOM_upgrade]$wget http://download.sipxcom.org/pub/sipXecs/16.04/sipxecs-16.04.0-centos.repo
```

**Step 4. Write a shell script that will perform yum update**
```
#! /bin/bash
yum clean all && yum update -y && reboot
```

**Step 5. Create ansible playbook that will upgrade sipxcom cluster**
```
---
- hosts: all
  tasks:
    - name: Copy sipxcom.repo in /etc/yum.repos.d. Overwrite with latest repo file
      copy: src=sipxcom.repo dest=/etc/yum.repos.d/sipxcom.repo

- hosts: secondaries
  tasks:
    - name: Upgrading secondaries first
      shell: upgrade.sh

- hosts: uc1
  tasks:
    - name: Upgrade primary now
      shell: upgrade.sh

```

**Step 6. Let’s add all these steps under a single setup.sh shell script.**
That will be executed when you want to upgrade to the latest sipXcom version
```
#! /bin/bash
echo "To which version you want to upgrade?? ex:add just  16.04  "
read VERSION
echo "You will need wget to download locally latest repo. If you don't have it installed on your management machine please install it.."
wget http://download.sipxcom.org/pub/sipXecs/$VERSION/sipxecs-$VERSION.0-centos.repo

#renaming to sipxcom.repo. This is the repo used by me on the VBox machines. You should replace the one that you have under /etc/yum.repos.d
mv sipxecs-$VERSION.0-centos.repo sipxcom.repo

#running ansible-playbook that will upgrade your cluster

ansible-playbook upgrade_sipxcom.yml

```

**Step 7: Compare the current version of sipxcom with the old one:**

```
rpm -qa | grep sipxconfig

Before upgrade:
-bash-4.1# rpm -qa | grep sipxconfig
Sipxconfig-16.02-8284.b5a40.x86_64

After running setup.sh
-bash-4.1# rpm -qa | grep sipxconfig
sipxconfig-tftp-16.04-8602.ec5f8.x86_64
sipxconfig-ftp-16.04-8602.ec5f8.x86_64
sipxconfig-16.04-8602.ec5f8.x86_64
```







