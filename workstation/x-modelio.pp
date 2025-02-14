###
# Puppet Script for Modelio on Ubuntu 24.04
###

$modelio_version = '5.4.1'
$modelio_major_version = '5.4'

exec { 'download-modelio-deb':
  command => "/usr/bin/curl -L http://static.evolvedbinary.com/cityehr/modelio-open-source-${modelio_version}-patched-adam_amd64.deb -o /tmp/modelio.deb",
  unless  => '/usr/bin/dpkg -s modelio',
  require => Package['curl'],
}

package { "modelio-open-source${modelio_major_version}":
  ensure  => installed,
  source  => '/tmp/modelio.deb',
  require => [
    Package['desktop'],
    Exec['download-modelio-deb'],
  ],
}

file { 'modelio-desktop-shortcut':
  ensure  => file,
  path    => "/home/${default_user}/Desktop/modelio.desktop",
  source  => "/usr/share/applications/modelio-open-source${modelio_major_version}.desktop",
  owner   => $default_user,
  group   => $default_user,
  mode    => '0644',
  require => [
    Package['desktop'],
    File['default_user_desktop_folder'],
    Package["modelio-open-source${modelio_major_version}"],
  ],
}

exec { 'gvfs-trust-modelio-desktop-shortcut':
  command     => "/usr/bin/gio set /home/${default_user}/Desktop/modelio.desktop metadata::trusted true",
  unless      => "/usr/bin/gio info --attributes=metadata::trusted /home/${default_user}/Desktop/modelio.desktop | /usr/bin/grep trusted",
  user        => $default_user,
  environment => [
    'DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus',
  ],
  require     => File['modelio-desktop-shortcut'],
}

ini_setting { 'modelio-shortcut-position':
  ensure  => present,
  path    => "/home/${default_user}/.config/pcmanfm-qt/lxqt/desktop-items-0.conf",
  section => 'modelio.desktop',
  setting => 'pos',
  value   => '@Point(393 390)',
  require => [
    File['desktop-items-0'],
    File['modelio-desktop-shortcut'],
  ],
}
