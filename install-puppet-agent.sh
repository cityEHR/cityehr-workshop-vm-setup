#!/usr/bin/env bash

set -e

PUPPET_VER=8
PUPPET_BIN=/opt/puppetlabs/bin/puppet
PUPPET_INSTALLED=false

# FreeBSD Ports
if [[ "$(uname)" == 'FreeBSD' ]]; then
	pkg info puppet$PUPPET_VER > /dev/null && pkg_puppet_exit_code=$? || pkg_puppet_exit_code=$? ; true
	if [[ ${pkg_puppet_exit_code} -ne 0 ]]; then
		# Puppet is not installed

		# Are port-maintenance-tools installed?
		pkg info port-maintenance-tools > /dev/null && pkg_pmt_exit_code=$? || pkg_pmt_exit_code=$? ; true

		if [ -d "/usr/ports/sysutils/puppet$PUPPET_VER" ]; then
			# If ports are present, install from ports
			pushd /usr/ports/sysutils/puppet$PUPPET_VER
			BATCH=yes make install clean
			popd

			# install port-maintenance-tools
			if [[ ${pkg_pmt_exit_code} -ne 0 ]]; then
				# install port-maintenance-tools
				pushd /usr/ports/ports-mgmt/port-maintenance-tools
				BATCH=yes make install clean
				popd
			fi
		else
			# Else, install from pkg
			pkg install -y puppet$PUPPET_VER

			if [[ ${pkg_pmt_exit_code} -ne 0 ]]; then
				# install port-maintenance-tools
				pkg install -y port-maintenance-tools
			fi
		fi
	fi
	PUPPET_BIN=/usr/local/bin/puppet
	PUPPET_INSTALLED=true

# RHEL 7 compatible
elif [ -n "$(command -v rpm)" ]; then
	rpm -Uvh https://yum.puppet.com/puppet$PUPPET_VER-release-el-7.noarch.rpm
	yum -y install puppet-agent
	PUPPET_INSTALLED=true

# Debian compatible
elif [ -n "$(command -v dpkg)" ]; then
	DISTRO_CODENAME="$(lsb_release -sc)"
	pushd /tmp
	wget https://apt.puppetlabs.com/puppet$PUPPET_VER-release-$DISTRO_CODENAME.deb
	dpkg -i puppet$PUPPET_VER-release-$DISTRO_CODENAME.deb
	rm puppet$PUPPET_VER-release-$DISTRO_CODENAME.deb
	popd
	apt-get update
	apt-get install -y puppet-agent
	PUPPET_INSTALLED=true
fi

if [[ $PUPPET_INSTALLED != "true" ]]; then
	echo "Could not locate ports, pkg, rpm, or dpkg to install puppet"
	exit 1
fi

# non-platform specific puppet modules
puppet_modules=(
	puppetlabs-stdlib
	saz-ssh
	puppetlabs-sshkeys_core
	puppetlabs-vcsrepo
	puppetlabs-augeas_core
	puppetlabs-inifile
	puppet-nginx
	puppet-letsencrypt
)
for puppet_module in "${puppet_modules[@]}"
do
	$PUPPET_BIN module install $puppet_module
done

if [[ "$(uname)" == 'FreeBSD' ]]; then
	# FreeBSD specific puppet modules
	$PUPPET_BIN module install ptomulik-portsng
fi

if [ -n "$(command -v yum)" ]; then
	# RHEL specific puppet modules
	$PUPPET_BIN module install puppet-yum
fi

if [ -n "$(command -v dpkg)" ]; then
	# Ubuntu specific puppet modules
	$PUPPET_BIN module install domkrm-ufw
fi

if [ -n "$(command -v apt)" ]; then
	# Apt specific puppet modules
	$PUPPET_BIN module install puppetlabs-apt
fi
