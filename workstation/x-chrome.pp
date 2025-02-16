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

xdesktop::shortcut { 'Chrome':
  shortcut_source => '/usr/share/applications/google-chrome.desktop',
  user            => $custom_user,
  position        => {
    provider => 'lxqt',
    x        => 139,
    y        => 12,
  },
  require         => [
    Package['desktop'],
    File['custom_user_desktop_folder'],
    File['desktop-items-0'],
    Package['google-chrome-stable'],
  ],
}
