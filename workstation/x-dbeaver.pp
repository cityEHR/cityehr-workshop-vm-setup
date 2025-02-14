###
# Puppet Script for DBeaver on Ubuntu 24.04
###

include apt

apt::source { 'dbeaver':
  location => 'https://dbeaver.io/debs/dbeaver-ce',
  release  => '',
  repos    => '/',
  comment  => 'DBeaver',
  key      => {
    id     => '98F5A7CC1ABE72AC3852A007D33A1BD725ED047D',
    name   => 'dbeaver.gpg.key',
    source => 'https://dbeaver.io/debs/dbeaver.gpg.key',
  },
  notify   => Exec['apt_update'],
}

package { 'dbeaver-ce':
  ensure  => installed,
  require => [
    Package['desktop'],
    Package['temurin-17-jdk'],
    Apt::Source['dbeaver'],
  ],
}

file { 'dbeaver-ce-desktop-shortcut':
  ensure  => file,
  path    => "/home/${custom_user}/Desktop/dbeaver-ce.desktop",
  source  => '/usr/share/applications/dbeaver-ce.desktop',
  owner   => $custom_user,
  group   => $custom_user,
  mode    => '0644',
  require => [
    Package['desktop'],
    File['custom_user_desktop_folder'],
    Package['dbeaver-ce'],
  ],
}

exec { 'gvfs-trust-dbeaver-ce-shortcut':
  command     => "/usr/bin/dbus-launch gio set /home/${custom_user}/Desktop/dbeaver-ce.desktop metadata::trusted true",
  unless      => "/usr/bin/dbus-launch gio info --attributes=metadata::trusted /home/${custom_user}/Desktop/dbeaver-ce.desktop | /usr/bin/grep trusted",
  user        => $custom_user,
  environment => [
    'DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus',
  ],
  require     => File['dbeaver-ce-desktop-shortcut'],
}

ini_setting { 'dbeaver-ce-desktop-shortcut-position':
  ensure  => present,
  path    => "/home/${custom_user}/.config/pcmanfm-qt/lxqt/desktop-items-0.conf",
  section => 'dbeaver-ce.desktop',
  setting => 'pos',
  value   => '@Point(266 12)',
  require => [
    File['desktop-items-0'],
    File['dbeaver-ce-desktop-shortcut'],
  ],
}
