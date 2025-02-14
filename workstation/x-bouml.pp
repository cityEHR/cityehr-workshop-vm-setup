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

$bouml_desktop_entry = @("BOUML_DESKTOP_ENTRY_EOF"/L)
  [Desktop Entry]
  Version=1.0
  Type=Application
  Name=BOUML
  Exec=${bouml_bin}
  Terminal=false
  StartupNotify=false
  GenericName=BOUML
  | BOUML_DESKTOP_ENTRY_EOF

file { 'bouml-shortcut':
  ensure  => file,
  path    => "/home/${custom_user}/Desktop/bouml.desktop",
  owner   => $custom_user,
  group   => $custom_user,
  mode    => '0644',
  content => $bouml_desktop_entry,
  require => [
    Package['desktop'],
    File['custom_user_desktop_folder'],
    File[$bouml_path]
  ],
}

exec { 'gvfs-trust-bouml-shortcut':
  command     => "/usr/bin/dbus-launch gio set /home/${custom_user}/Desktop/bouml.desktop metadata::trusted true",
  unless      => "/usr/bin/dbus-launch gio info --attributes=metadata::trusted /home/${custom_user}/Desktop/bouml.desktop | /usr/bin/grep trusted",
  user        => $custom_user,
  environment => [
    'DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus',
  ],
  require     => File['bouml-shortcut'],
}

ini_setting { 'bouml-shortcut-position':
  ensure  => present,
  path    => "/home/${custom_user}/.config/pcmanfm-qt/lxqt/desktop-items-0.conf",
  section => 'bouml.desktop',
  setting => 'pos',
  value   => '@Point(266 642)',
  require => [
    File['desktop-items-0'],
    File['bouml-shortcut'],
  ],
}
