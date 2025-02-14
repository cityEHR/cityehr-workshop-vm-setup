###
# Puppet Script for Protege on Ubuntu 24.04
###

$protege_version = '5.6.5'
$protege_path = '/opt/protege'
$protege_bin = "${protege_path}/protege"

file { $protege_path:
  ensure  => directory,
  replace => false,
  owner   => 'root',
  group   => 'root',
}

exec { 'download-protege-tgz':
  command => "curl -L https://github.com/protegeproject/protege-distribution/releases/download/protege-${protege_version}/Protege-${protege_version}-linux.tar.gz | tar zxv -C ${protege_path} --strip-components=1",
  path    => '/usr/bin',
  user    => 'root',
  group   => 'root',
  creates => $protege_bin,
  require => [
    Package['file'],
    Package['curl'],
    File[$protege_path]
  ],
}

xdesktop::shortcut { 'Protege':
  application_path => $protege_bin,
  application_icon => "${protege_path}/app/Protege.ico",
  user             => $custom_user,
  position         => {
    provider => 'lxqt',
    x        => 266,
    y        => 264,
  },
  require          => [
    Package['desktop'],
    File['custom_user_desktop_folder'],
    File['desktop-items-0'],
    File[$protege_path],
  ],
}
