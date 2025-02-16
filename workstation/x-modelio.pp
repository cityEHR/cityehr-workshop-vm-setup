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

xdesktop::shortcut { 'Modelio':
  shortcut_source => "/usr/share/applications/modelio-open-source${modelio_major_version}.desktop",
  user            => $custom_user,
  position        => {
    provider => 'lxqt',
    x        => 266,
    y        => 390,
  },
  require         => [
    Package['desktop'],
    File['custom_user_desktop_folder'],
    File['desktop-items-0'],
    Package["modelio-open-source${modelio_major_version}"],
  ],
}
