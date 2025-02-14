###
# Puppet Script for VSCode on Ubuntu 24.04
###

exec { 'download-vscode-deb':
  command => '/usr/bin/curl -L https://update.code.visualstudio.com/latest/linux-deb-x64/stable -o /tmp/vscode.deb',
  unless  => '/usr/bin/dpkg -s code',
  require => Package['curl'],
}

package { 'code':
  ensure  => installed,
  source  => '/tmp/vscode.deb',
  require => [
    Package['desktop'],
    Exec['download-vscode-deb'],
  ],
}

file_line { 'vscode-no-open-folder':
  ensure  => present,
  path    => '/usr/share/applications/code.desktop',
  line    => 'MimeType=text/plain;application/x-code-workspace;',
  match   => '^MimeType\=',
  require => Package['code'],
}

file { 'vscode-desktop-shortcut':
  ensure  => file,
  path    => "/home/${custom_user}/Desktop/code.desktop",
  source  => '/usr/share/applications/code.desktop',
  owner   => $custom_user,
  group   => $custom_user,
  mode    => '0644',
  require => [
    Package['desktop'],
    File['custom_user_desktop_folder'],
    File_line['vscode-no-open-folder'],
  ],
}

exec { 'gvfs-trust-vscode-desktop-shortcut':
  command     => "/usr/bin/dbus-launch gio set /home/${custom_user}/Desktop/code.desktop metadata::trusted true",
  unless      => "/usr/bin/dbus-launch gio info --attributes=metadata::trusted /home/${custom_user}/Desktop/code.desktop | /usr/bin/grep trusted",
  user        => $custom_user,
  environment => [
    'DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus',
  ],
  require     => File['vscode-desktop-shortcut'],
}

ini_setting { 'vscode-desktop-shortcut-position':
  ensure  => present,
  path    => "/home/${custom_user}/.config/pcmanfm-qt/lxqt/desktop-items-0.conf",
  section => 'code.desktop',
  setting => 'pos',
  value   => '@Point(139 768)',
  require => [
    File['desktop-items-0'],
    File['vscode-desktop-shortcut'],
  ],
}
