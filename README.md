# cityEHR Workshop - Virtual Machine

The following instructions will enable you to setup two things:

1. An [Apache Guacamole](https://guacamole.apache.org/) server that will provide a website for accessing remote machines through a Web Browser.

2. One or More Virtual Machines configured with all of the software required for the purpose of teaching a cityEHR workshop.

## Obtaining Servers

This can be setup either in [AWS EC2](https://aws.amazon.com/ec2/), or another Virtual Environment such as KVM running on a Linux Server.
The environment (which provided 1x Guacamole Server, and 9x cityEHR Virtual Machines) and that was used for the workshops delivered in Ukraine (August 2024) and XML Summer School (September 2024) was Ubuntu 24.04 running on a bare-metal server leased by Evolved Binary from [Hetzner](https://www.hetzner.com/) in Germany, with the following configuration:
* Xeon E5-1650 v3 @ 3.50GHz (6 Cores / 12 Threads)
* 128 GB RAM
* 2x 480GB SSD in RAID 1

Below we detail two options for setting up Virtual Machines: 1. Hetzner bare-metal server, and 2. AWS EC2.

### 1. Setting up a new Linux KVM VM (optional)

If you have leased a server from someone like Hetzner with Ubuntu 24.04 installed and wish to set this all up using KVM to host your VMs, then on the server (KVM host) you should run the following commands (assuming an Evolved Binary Server in Hetzner):

```shell
git clone --single-branch --branch hetzner https://github.com/adamretter/soyoustart hetzner
cd ~/hetzner

sudo uvt-simplestreams-libvirt sync --source=http://cloud-images.ubuntu.com/minimal/releases arch=amd64 release=noble

./create-uvt-kvm.sh --hostname cityehr-work-01 --release noble --memory 14336 --disk 30 --cpu 4 --bridge virbr1 --ip 5.9.214.101 --ip6 2a01:4f8:212:be9::101 --gateway 136.243.43.238 --gateway6 2a01:4f8:212:be9::2 --dns 213.133.100.100 --dns 213.133.99.99 --dns 213.133.98.98 --dns-search evolvedbinary.com --autostart
```

**NOTE**: There is an issue at the moment with the 2nd private interface not being activated until the VM is shutdown and re-launched. So before you login to the VM fo rthe first time, please wait a few minutes so the VM finishes starting up, and then run:

```shell
virsh shutdown cityehr-work-01
```

You should then check the status of the VM until it is shutdown. You can do that by running: `virsh domstate cityehr-work-01`. When the state is `shut off`, you can then restart the VM by running:

```shell
virsh cityehr-work-01
```

**NOTE**: The VM specific settings are:
* `--hostname` `cityehr-work-01`
* `--ip` `5.9.214.101`
* `--ip6` `2a01:4f8:212:be9::101`

**NOTE**: The network settings specific to the host are:
* `--bridge` `virbr1`
* `--gateway` `136.243.43.238`
* `--gateway6` `2a01:4f8:212:be9::2`

**NOTE**: The network settings specific to the hosting provider are:
* `--dns 213.133.100.100`, `--dns 213.133.99.99`, `--dns 213.133.98.98`


### 2. Setting up a new AWS EC2 Instance (optional)

If you wish to set this up in AWS EC2, then for each Virtual Machine you need should setup a new EC2 instance with the following properties:

1. Name the instance 'cityehr-work-01'. (change the `01` as needed for more machines).

2. Select the `Ubuntu Server 24.04 LTS (HVM), SSD Volume Type` AMI image, and the Architecture `amd64`.

3. Select `m6g.xlarge` instance type. (i.e.: 4vCPU, 16GB Memory, 1x237 NVMe SSD, $0.1776 / hour).

4. Select the `cityehr-work` keypair.

5. Select the `cityehr-work vm` Security Group.

6. Set the default Root Volume as an `EBS` `30 GiB` volume on `GP3` at `3000 IOPS` and `125 MiB throughput`.


## Installing Guacamole Server

Apache Guacamole provides a web interface for accessing any virtual machine remotely. This is used so that students only need a web-browser. The student accesses Guacamole, and then Guacamole connects them to the remote virtual machine.

Guacamole should be run in its own virtual machine. To install Guacamole and configure it for cityEHR run the following commands on a new VM:

```shell
git clone https://github.com/evolvedbinary/cityehr-workshop-vm-setup.git
cd cityehr-workshop-vm-setup
sudo ./install-puppet-agent.sh

cd guacamole

sudo FACTER_default_user_password=mypassword2 \
     /opt/puppetlabs/bin/puppet apply 01-base.pp
```

**NOTE:** you should set your own passwords appropriately above! The `default_user_password` is used for the Linux user that can access the machine, the username is `ubuntu`.

We have to restart the system after the above as it may install a new Kernel and make changes to settings that require a system reboot. So run:

```shell
sudo shutdown -r now
```

After the system restarts and you have logged in, you need to resume from the `cityehr-workshop-vm-setup/guacamole` repo checkout:

```shell
cd cityehr-workshop-vm-setup/guacamole

sudo FACTER_default_user_password=mypassword2 \
     FACTER_cityehrwork_default_user_password=mypassword
     /opt/puppetlabs/bin/puppet apply .
```

**NOTE:** you should set your own passwords appropriately above!

* `default_user_password` this is the password to set for the default linux user on this machine (typically the user is named `ubuntu` on Ubuntu Cloud images).
* `cityehrwork_default_user_password` should be set to the password of the default user on the remote (cityEHR workstation) virtual machines that you are trying to access.

After installation Guacamole's Web Server should be accessible from: [http://localhost:8080](http://localhost:8080), but should be accessible (via an nginx reverse proxy) from: [https://localhost](https://localhost)


## Installing a cityEHR Workstation

You can install one or more cityEHR workstations, each should be configured within its own virtual (or physical) machine. We expect to start from a clean Ubuntu Server, or Ubuntu Cloud Image install. This has been tested with Ubuntu version 24.04 LTS (x86_64).

### cityEHR Software Environment

The following software will be configured:

* Desktop Environment
	* X.org
	* LXQt
	* Chromium
	* Firefox
	* Okular

* Java Development Environment
	* JDK 11
	* JDK 17
	* Apache Maven 3
	* IntelliJ IDEA CE
	* Apache Tomcat 9
	* Quercus

* Database Environment
	* MariaDB Server and Client
	* MySQL Workbench
	* DBeaver

* cityEHR

* cityEHR Workshop Tools
	* Mirth Connect and Mirth Administrator
	* Oxygen XML Editor
	* LibreOffice
	* Protégé
	* Inkscape
	* GanttProject
	* FreeMind
	* BOUML
	* Modelio

* Visual Studio Code

* Miscellaneous Tools
	* Nullmailer
	* Zsh and OhMyZsh
	* Git
	* cURL
	* wget
	* Screen
	* tar, gzip, bzip2, zstd, zip (and unzip)


### Installing a cityEHR Workstation

Each cityEHR Workstation should be run in its own virtual machine. To install a cityEHR workstation run the following commands on a new VM:

```shell
git clone https://github.com/evolvedbinary/cityehr-workshop-vm-setup.git
cd cityehr-workshop-vm-setup
sudo ./install-puppet-agent.sh

cd workstation

sudo /opt/puppetlabs/bin/puppet apply 00-locale.pp

sudo FACTER_default_user_password=mypassword \
     /opt/puppetlabs/bin/puppet apply --modulepath=/etc/puppetlabs/code/environments/production/modules:$(pwd)/modules \
	 01-base.pp
```

**NOTE:** you should set your own passwords appropriately above!

* `default_user_password` this is the password to set for the default linux user on this machine (typically the user is named `ubuntu` on Ubuntu Cloud images).

We have to restart the system after the above as it may install a new Kernel and make changes to settings that require a system reboot. So:

```shell
sudo shutdown -r now
```

After the system restarts and you have logged in, you need to resume from the `cityehr-workshop-vm-setup/workstation` repo checkout:

```shell
cd cityehr-workshop-vm-setup/workstation
sudo FACTER_default_user_password=mypassword \
  FACTER_override_custom_user=adam.retter \
  FACTER_override_custom_user_password=cityehr \
  FACTER_mariadb_db_root_password=cityehrwork \
  /opt/puppetlabs/bin/puppet apply --modulepath=/etc/puppetlabs/code/environments/production/modules:$(pwd)/modules \
  .
```

**NOTE:** you should set your own passwords appropriately above!

* `default_user_password` this is the password to set for the default linux user (typically the user is named `ubuntu` on Ubuntu Cloud images). It needs to be the same as the password you used for this above.
* `override_custom_user` this is the username for the linux user account to add to this machine (e.g. for the Student). If not specified, defaults to: `student`.
* `override_custom_user_password` this is a password for the custom user account. If not specified, defaults to: `student`.
* `mariadb_db_root_password` - This is the password to set for the `root` user in MariaDB.

We have to restart the system after the above as it installs a new desktop login manager.

```shell
sudo shutdown -r now
```

After installation you should be able to access this instance using either one of two mechanisms:

1. Directly, by using an RDP (Remote Desktop Protocol) client, e.g. Microsoft Remote Desktop. This approach usually gives the most responsive performance for the user.
	* Clients:
		* **Windows** - run `mstsc.exe`
		* **Mac** - Install and run (Microsoft Remote Desktop](https://apps.apple.com/us/app/microsoft-remote-desktop/id1295203466?mt=12) from the Apple Store.
		* **Linux** - run `rdesktop` (Ubuntu install: `apt-get install -y rdesktop && rdesktop`)
	* Connection Settings:
		* **Host**: The IP address or FQDN of the remote machine (e.g. `cityehr-work-01.evolvedbinary.com`)
		* **Username**: `ubuntu`
		* **Password**: *the password you set above for `default_user_password`*


2. Indirectly via the Guacamole website by visiting the website (e.g. [https://plum.evolvedbinary.com](https://plum.evolvedbinary.com)) in your web browser.
	* Login details:
		* **Username**: `cityehr-work-01` (replace the `01` with the relevant number for the instance)
		* **Password**: *the password you set above for `cityehrwork_default_user_password`*
