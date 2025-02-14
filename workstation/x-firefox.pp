###
# Puppet Script for Firefox on Ubuntu 24.04
###

package { 'firefox':
  ensure  => installed,
  require => Package['desktop'],
}

$firefox_desktop_shortcut =  @("FIREFOX_SHORTCUT_EOF"/L)
  [Desktop Entry]
  Version=1.0
  Name=Firefox
  Exec=/usr/bin/firefox
  StartupNotify=true
  Terminal=false
  Icon=/usr/share/icons/hicolor/128x128/apps/firefox.png
  Type=Application
  | FIREFOX_SHORTCUT_EOF

file { 'firefox-desktop-shortcut':
  ensure  => file,
  path    => "/home/${custom_user}/Desktop/firefox.desktop",
  content => $firefox_desktop_shortcut,
  owner   => $custom_user,
  group   => $custom_user,
  mode    => '0644',
  require => [
    Package['desktop'],
    File['custom_user_desktop_folder'],
    Package['firefox'],
  ],
}

exec { 'gvfs-trust-firefox-shortcut':
  command     => "/usr/bin/dbus-launch gio set /home/${custom_user}/Desktop/firefox.desktop metadata::trusted true",
  unless      => "/usr/bin/dbus-launch gio info --attributes=metadata::trusted /home/${custom_user}/Desktop/firefox.desktop | /usr/bin/grep trusted",
  user        => $custom_user,
  environment => [
    'DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus',
  ],
  require     => File['firefox-desktop-shortcut'],
}

ini_setting { 'firefox-desktop-shortcut-position':
  ensure  => present,
  path    => "/home/${custom_user}/.config/pcmanfm-qt/lxqt/desktop-items-0.conf",
  section => 'firefox.desktop',
  setting => 'pos',
  value   => '@Point(139 12)',
  require => [
    File['desktop-items-0'],
    File['firefox-desktop-shortcut'],
  ],
}
