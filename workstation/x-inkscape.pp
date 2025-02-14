###
# Puppet Script for Inkscape on Ubuntu 24.04
###

package { 'inkscape':
  ensure  => installed,
  require => Package['desktop'],
}

file { 'inkscape-desktop-shortcut':
  ensure  => file,
  path    => "/home/${custom_user}/Desktop/inkscape.desktop",
  source  => '/usr/share/applications/org.inkscape.Inkscape.desktop',
  owner   => $custom_user,
  group   => $custom_user,
  mode    => '0644',
  require => [
    Package['desktop'],
    File['custom_user_desktop_folder'],
    Package['inkscape'],
  ],
}

exec { 'gvfs-trust-inkscape-shortcut':
  command     => "/usr/bin/dbus-launch gio set /home/${custom_user}/Desktop/inkscape.desktop metadata::trusted true",
  unless      => "/usr/bin/dbus-launch gio info --attributes=metadata::trusted /home/${custom_user}/Desktop/inkscape.desktop | /usr/bin/grep trusted",
  user        => $custom_user,
  environment => [
    'DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus',
  ],
  require     => File['inkscape-desktop-shortcut'],
}

ini_setting { 'inkscape-desktop-shortcut-position':
  ensure  => present,
  path    => "/home/${custom_user}/.config/pcmanfm-qt/lxqt/desktop-items-0.conf",
  section => 'inkscape.desktop',
  setting => 'pos',
  value   => '@Point(139 516)',
  require => [
    File['desktop-items-0'],
    File['inkscape-desktop-shortcut'],
  ],
}
