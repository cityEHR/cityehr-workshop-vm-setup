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

$mirth_administrator_desktop_entry = @("MIRTH_ADMINISTRATOR_DESKTOP_ENTRY_EOF"/L)
  [Desktop Entry]
  Version=1.0
  Type=Application
  Name=Mirth Administrator
  Exec=${mirth_administrator_path}/launcher
  Icon=${mirth_administrator_path}/mcadministrator/unix/launcher.ico
  Terminal=false
  StartupNotify=false
  GenericName=Mirth Administrator
  | MIRTH_ADMINISTRATOR_DESKTOP_ENTRY_EOF

file { 'mirth-administrator-shortcut':
  ensure  => file,
  path    => "/home/${custom_user}/Desktop/mirth-administrator.desktop",
  owner   => $custom_user,
  group   => $custom_user,
  mode    => '0644',
  content => $mirth_administrator_desktop_entry,
  require => [
    Package['desktop'],
    File['custom_user_desktop_folder'],
    File[$mirth_administrator_path]
  ],
}

exec { 'gvfs-trust-mirth-administrator-shortcut':
  command     => "/usr/bin/dbus-launch gio set /home/${custom_user}/Desktop/mirth-administrator.desktop metadata::trusted true",
  unless      => "/usr/bin/dbus-launch gio info --attributes=metadata::trusted /home/${custom_user}/Desktop/mirth-administrator.desktop | /usr/bin/grep trusted",
  user        => $custom_user,
  environment => [
    'DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus',
  ],
  require     => File['mirth-administrator-shortcut'],
}

ini_setting { 'mirth-administrator-shortcut-position':
  ensure  => present,
  path    => "/home/${custom_user}/.config/pcmanfm-qt/lxqt/desktop-items-0.conf",
  section => 'mirth-administrator.desktop',
  setting => 'pos',
  value   => '@Point(393 12)',
  require => [
    File['desktop-items-0'],
    File['mirth-administrator-shortcut'],
  ],
}
