###
# Puppet Script for a Base System on Ubuntu 24.04
###

include ufw

# Set the version of Ubuntu
$ubuntu_version = '24.04'
$default_user = 'ubuntu'

# setup automatic security updates
package { 'unattended-upgrades':
  ensure => installed,
}

$apt_auto_upgrades = @("APT_AUTO_UPGRADES_EOF"/L)
  APT::Periodic::Update-Package-Lists "1";
  APT::Periodic::Unattended-Upgrade "1";
  | APT_AUTO_UPGRADES_EOF

file { '/etc/apt/apt.conf.d/20auto-upgrades':
  ensure  => file,
  content => $apt_auto_upgrades,
  owner   => 'root',
  group   => 'root',
  mode    => '0644',
  require => Package['unattended-upgrades'],
}

# update to the HWE kernel for Ubuntu LTS
package { "linux-generic-hwe-${ubuntu_version}":
  ensure          => installed,
  install_options => ['--install-recommends'],
}

# configure the 'ubuntu' user and their home folder
package { 'zsh':
  ensure => installed,
}

group { 'sudo':
  ensure          => present,
  auth_membership => true,
}

group { 'default_user':
  ensure => present,
  name   => $default_user,
}

user { 'default_user':
  ensure     => present,
  name       => $default_user,
  gid        => $default_user,
  groups     => [
    'adm',
    'dialout',
    'cdrom',
    'floppy',
    'sudo',
    'audio',
    'dip',
    'video',
    'plugdev',
    'lxd',
    'netdev',
  ],
  comment    => "${default_user} default user",
  managehome => true,
  shell      => '/usr/bin/zsh',
  password   => pw_hash($default_user_password, 'SHA-512', 'mysalt'),
  require    => [
    Group['default_user'],
    Group['sudo'],
    Package['zsh'],
  ],
}

file { 'default_user_home':
  ensure  => directory,
  path    => "/home/${default_user}",
  replace => false,
  owner   => $default_user,
  group   => $default_user,
  mode    => '0700',
  require => User['default_user'],
}

file { 'default_user_code_folder':
  ensure  => directory,
  path    => "/home/${default_user}/code",
  replace => false,
  owner   => $default_user,
  group   => $default_user,
  require => [
    User['default_user'],
    File['default_user_home'],
  ],
}

ssh_authorized_key { 'cityehrwork':
  ensure  => present,
  user    => $default_user,
  type    => 'ssh-ed25519',
  key     => 'AAAAC3NzaC1lZDI1NTE5AAAAIEwexg8HSsaumrYw5Kd2qGZSbjCbgqJR5wo8rEj+gPfC',
  require => User['default_user'],
}

ssh_authorized_key { 'aretter@hollowcore.local':
  ensure  => present,
  user    => $default_user,
  type    => 'ssh-rsa',
  key     => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQDHvJ21M2Jfw75K82bEdZIhL9t7N8kUuXOPxKWFs7o6Z+42UGH47lmQrk95OJdhLxlp2paGFng++mMLV1Xf7uLjTUE8lJHJv/TSzC81Q5NSfFXQTn4kpr5BRKgTnXPNYTHcsueeUr6auZDThVG3mU62AvieFeI5MJOE7FlAS4++u2pVG7+H4l48snlKiUDH5oXRLdJtZbED2v6byluSkj6uNThEYoHzHRxvF8Lo12NgQEMBVrHyvBWtHPpZIhCzzzsTEf9+249VqsO3NqTl7vswMhf8z2NYgGjf0w+5A3bJDIpvDRWQ+40uB1bdwqUDuiY8nGSSKwpVOby0cYZjfhjZ',
  require => User['default_user'],
}

package { 'curl':
  ensure => installed,
}

exec { 'install-ohmyzsh':
  command => 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"',
  path    => '/usr/bin',
  user    => $default_user,
  require => [
    Package['curl'],
    Package['zsh'],
    Package['git'],
    User['default_user']
  ],
  creates => "/home/${default_user}/.oh-my-zsh",
}

package { 'openssh-server':
  ensure => installed,
}

class { 'ssh':
  storeconfigs_enabled => false,
  validate_sshd_file   => true,
  server_options       => {
    'Port'                            => [22],
    'HostKey'                         => [
      '/etc/ssh/ssh_host_rsa_key',
      '/etc/ssh/ssh_host_ecdsa_key',
      '/etc/ssh/ssh_host_ed25519_key',
    ],
    'SyslogFacility'                  => 'AUTHPRIV',
    'AuthorizedKeysFile'              => '.ssh/authorized_keys',
    'PermitRootLogin'                 => 'no',
    'PasswordAuthentication'          => 'yes',
    'ChallengeResponseAuthentication' => 'no',
    'GSSAPIAuthentication'            => 'yes',
    'GSSAPICleanupCredentials'        => 'yes',
    'UsePAM'                          => 'yes',
    'X11Forwarding'                   => 'yes',
    'PrintMotd'                       => 'yes',
    'AllowTcpForwarding'              => 'no',
    'AcceptEnv'                       => [
      'LANG LC_CTYPE LC_NUMERIC LC_TIME LC_COLLATE LC_MONETARY LC_MESSAGES',
      'LC_PAPER LC_NAME LC_ADDRESS LC_TELEPHONE LC_MEASUREMENT',
      'LC_IDENTIFICATION LC_ALL LANGUAGE',
      'XMODIFIERS',
    ],
  },
  users_client_options => {
    "${default_user}" => {
      options => {
        'HashKnownHosts' => 'yes',
      },
    },
  },
  require              => Package['openssh-server'],
}

# setup default firewall rules
ufw::allow { 'ssh':
  port    => '22',
  require => Class['ssh'],
}

# install miscellaneous system packages
package { 'chrony':
  ensure => installed,
}

service { 'chronyd':
  ensure  => running,
  enable  => true,
  require => Package['chrony'],
}

package { 'file':
  ensure => installed,
}

package { 'zip':
  ensure => installed,
}

package { 'unzip':
  ensure => installed,
}

package { 'tar':
  ensure => installed,
}

package { 'gzip':
  ensure => installed,
}

package { 'bzip2':
  ensure => installed,
}

package { 'zstd':
  ensure => installed,
}

package { 'wget':
  ensure => installed,
}

package { 'screen':
  ensure => installed,
}

package { 'git':
  ensure => installed,
}
