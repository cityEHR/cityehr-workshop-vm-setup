###
# Puppet Script for setting locale on Ubuntu 24.04
###

# Set the language
exec { 'set-language':
  command => '/usr/sbin/update-locale LANG=en_GB.utf8',
  user    => 'root',
  unless  => '/usr/bin/locale | /usr/bin/grep LANG=en_GB.utf8',
}

file { '/etc/default/keyboard':
  ensure  => file,
  replace => false,
  owner   => 'root',
  group   => 'root',
  mode    => '0744',
}

# Set the keyboard layout
file_line { 'keyboard-layout':
  ensure => present,
  path   => '/etc/default/keyboard',
  line   => 'XKBLAYOUT="gb,us,fr,nl"',
  match  => '^XKBLAYOUT\=',
}

# Set the time zone
exec { 'set-timezone':
  command => 'timedatectl set-timezone Europe/London',
  path    => '/usr/bin',
  user    => 'root',
  unless  => 'cat /etc/timezone | grep Europe/London',
}
