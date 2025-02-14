###
# Puppet Script for setting locale on Ubuntu 24.04
###

$locale = 'en_GB'
$xkbd_layout = 'gb,us,fr,nl'
$time_zone = 'Europe/London'

# Set the language
exec { 'generate-language':
  command => "/usr/sbin/locale-gen ${locale}.utf8",
  user    => 'root',
  unless  => "/usr/bin/localectl list-locales | /usr/bin/grep ${locale}.utf8",
}

exec { 'set-language':
  command => "/usr/sbin/update-locale LANG=${locale}.utf8",
  user    => 'root',
  unless  => "/usr/bin/locale | /usr/bin/grep LANG=${locale}.utf8",
  require => Exec['generate-language'],
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
  line   => "XKBLAYOUT=\"${xkbd_layout}\"",
  match  => '^XKBLAYOUT\=',
}

# Set the time zone
exec { 'set-timezone':
  command => "timedatectl set-timezone ${time_zone}",
  path    => '/usr/bin',
  user    => 'root',
  unless  => "cat /etc/timezone | grep ${time_zone}",
}
