###
# Puppet Script for BOUML on Ubuntu 24.04
###

$bouml_path = '/opt/bouml'
$bouml_bin = "${bouml_path}/bin/bouml"

file { $bouml_path:
  ensure  => directory,
  replace => false,
  owner   => 'root',
  group   => 'root',
}

exec { 'download-bouml-tgz':
  command => "curl https://www.bouml.fr/files/bouml_ubuntu_amd64.tar.gz | tar zxv -C ${bouml_path}",
  path    => '/usr/bin',
  user    => 'root',
  group   => 'root',
  creates => "${bouml_path}/bin",
  unless  => "test -f ${bouml_bin}",
  require => [
    Package['file'],
    Package['curl'],
    File[$bouml_path]
  ],
}

xdesktop::shortcut { 'BOUML':
  application_path => $bouml_bin,
  user             => $custom_user,
  position         => {
    provider => 'lxqt',
    x        => 266,
    y        => 642,
  },
  require          => [
    Package['desktop'],
    File['custom_user_desktop_folder'],
    File['desktop-items-0'],
    File[$bouml_path]
  ],
}
