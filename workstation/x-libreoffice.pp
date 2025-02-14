###
# Puppet Script for LibreOffice on Ubuntu 24.04
###

package { 'libreoffice':
  ensure  => installed,
  require => Package['desktop'],
}

file { 'libreoffice-writer-desktop-shortcut':
  ensure  => file,
  path    => "/home/${custom_user}/Desktop/libreoffice-writer.desktop",
  source  => '/usr/share/applications/libreoffice-writer.desktop',
  owner   => $custom_user,
  group   => $custom_user,
  mode    => '0644',
  require => [
    Package['desktop'],
    File['custom_user_desktop_folder'],
    Package['libreoffice'],
  ],
}

exec { 'gvfs-trust-libreoffice-writer-shortcut':
  command     => "/usr/bin/dbus-launch gio set /home/${custom_user}/Desktop/libreoffice-writer.desktop metadata::trusted true",
  unless      => "/usr/bin/dbus-launch gio info --attributes=metadata::trusted /home/${custom_user}/Desktop/libreoffice-writer.desktop | /usr/bin/grep trusted",
  user        => $custom_user,
  environment => [
    'DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus',
  ],
  require     => File['libreoffice-writer-desktop-shortcut'],
}

file { 'libreoffice-calc-desktop-shortcut':
  ensure  => file,
  path    => "/home/${custom_user}/Desktop/libreoffice-calc.desktop",
  source  => '/usr/share/applications/libreoffice-calc.desktop',
  owner   => $custom_user,
  group   => $custom_user,
  mode    => '0644',
  require => [
    Package['desktop'],
    File['custom_user_desktop_folder'],
    Package['libreoffice'],
  ],
}

exec { 'gvfs-trust-libreoffice-calc-shortcut':
  command     => "/usr/bin/dbus-launch gio set /home/${custom_user}/Desktop/libreoffice-calc.desktop metadata::trusted true",
  unless      => "/usr/bin/dbus-launch gio info --attributes=metadata::trusted /home/${custom_user}/Desktop/libreoffice-calc.desktop | /usr/bin/grep trusted",
  user        => $custom_user,
  environment => [
    'DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus',
  ],
  require     => File['libreoffice-calc-desktop-shortcut'],
}

ini_setting { 'libreoffice-writer-desktop-shortcut-position':
  ensure  => present,
  path    => "/home/${custom_user}/.config/pcmanfm-qt/lxqt/desktop-items-0.conf",
  section => 'libreoffice-writer.desktop',
  setting => 'pos',
  value   => '@Point(139 264)',
  require => [
    File['desktop-items-0'],
    File['libreoffice-writer-desktop-shortcut'],
  ],
}

ini_setting { 'libreoffice-calc-desktop-shortcut-position':
  ensure  => present,
  path    => "/home/${custom_user}/.config/pcmanfm-qt/lxqt/desktop-items-0.conf",
  section => 'libreoffice-calc.desktop',
  setting => 'pos',
  value   => '@Point(139 390)',
  require => [
    File['desktop-items-0'],
    File['libreoffice-calc-desktop-shortcut'],
  ],
}
