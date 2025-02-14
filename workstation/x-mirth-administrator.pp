###
# Puppet Script for Mirth Administrator on Ubuntu 24.04
###

$mirth_administrator_path = '/opt/mirth-administrator'

file { $mirth_administrator_path:
  ensure  => directory,
  replace => false,
  owner   => 'root',
  group   => 'root',
}

exec { 'install-mirth-administrator':
  command => "curl https://s3.amazonaws.com/downloads.mirthcorp.com/connect-client-launcher/mirth-administrator-launcher-latest-unix.tar.gz | tar zxv -C ${mirth_administrator_path} --strip-components=1",
  path    => '/usr/bin',
  user    => 'root',
  group   => 'root',
  creates => "${mirth_administrator_path}/launcher",
  require => [
    Package['file'],
    Package['curl'],
    File[$mirth_administrator_path]
  ],
}

xdesktop::shortcut { 'Mirth Administrator':
  application_path => "${mirth_administrator_path}/launcher",
  application_icon => "${mirth_administrator_path}/mcadministrator/unix/launcher.ico",
  user             => $custom_user,
  position         => {
    provider => 'lxqt',
    x        => 393,
    y        => 12,
  },
  require          => [
    Package['desktop'],
    File['custom_user_desktop_folder'],
    File['desktop-items-0'],
    File[$mirth_administrator_path]
  ],
}
