###
# Puppet Script for Google Chrome on Ubuntu 24.04
###

exec { 'download-google-chrome-deb':
  command => '/usr/bin/wget -P /tmp https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb',
  unless  => '/usr/bin/dpkg -s google-chrome-stable',
  user    => 'root',
  require => Package['wget'],
}

package { 'google-chrome-stable':
  ensure  => installed,
  source  => '/tmp/google-chrome-stable_current_amd64.deb',
  require => [
    Package['desktop'],
    Exec['download-google-chrome-deb'],
  ],
}

file { 'google-chrome-desktop-shortcut':
  ensure  => file,
  path    => "/home/${custom_user}/Desktop/google-chrome.desktop",
  source  => '/usr/share/applications/google-chrome.desktop',
  owner   => $custom_user,
  group   => $custom_user,
  mode    => '0644',
  require => [
    Package['desktop'],
    File['custom_user_desktop_folder'],
    Package['google-chrome-stable'],
  ],
}

exec { 'gvfs-trust-google-chrome-desktop-shortcut':
  command     => "/usr/bin/dbus-launch gio set /home/${custom_user}/Desktop/google-chrome.desktop metadata::trusted true",
  unless      => "/usr/bin/dbus-launch gio info --attributes=metadata::trusted /home/${custom_user}/Desktop/google-chrome.desktop | /usr/bin/grep trusted",
  user        => $custom_user,
  environment => [
    'DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus',
  ],
  require     => File['google-chrome-desktop-shortcut'],
}

ini_setting { 'google-chrome-desktop-shortcut-position':
  ensure  => present,
  path    => "/home/${custom_user}/.config/pcmanfm-qt/lxqt/desktop-items-0.conf",
  section => 'google-chrome.desktop',
  setting => 'pos',
  value   => '@Point(139 138)',
  require => [
    File['desktop-items-0'],
    File['google-chrome-desktop-shortcut'],
  ],
}
