###
# Puppet Script for FreeMind on Ubuntu 22.04
###

$freemind_version = '1.0.1'
$freemind_path = '/opt/freemind'
$freemind_bin = "${freemind_path}/freemind.sh"

exec { 'download-freemind-zip':
  path    => '/usr/bin',
  command => "curl -L https://deac-riga.dl.sourceforge.net/project/freemind/freemind/${freemind_version}/freemind-bin-max-${freemind_version}.zip?viasf=1 -o /tmp/freemind-bin-max-${freemind_version}.zip",
  unless  => "test -f ${freemind_bin}",
  require => [
    Package['file'],
    Package['curl'],
  ],
}

file { '/opt/freemind':
  ensure  => directory,
  replace => false,
  owner   => 'root',
  group   => 'root',
}

exec { 'unzip-freemind':
  command => "unzip /tmp/freemind-bin-max-${freemind_version}.zip -d ${freemind_path}",
  path    => '/usr/bin',
  user    => 'root',
  group   => 'root',
  unless  => "test -f ${freemind_bin}",
  require => [
    Package['file'],
    Package['unzip'],
    Exec['download-freemind-zip'],
    File['/opt/freemind']
  ],
}

file { 'exec-freemind-sh':
  ensure  => file,
  path    => $freemind_bin,
  replace => false,
  mode    => '0755',
  owner   => 'root',
  group   => 'root',
  require => Exec['unzip-freemind'],
}

xdesktop::shortcut { 'FreeMind':
  application_path => $freemind_bin,
  user             => $custom_user,
  position         => {
    provider => 'lxqt',
    x        => 266,
    y        => 768,
  },
  require          => [
    Package['desktop'],
    File['custom_user_desktop_folder'],
    File['desktop-items-0'],
    File['/opt/freemind']
  ],
}
