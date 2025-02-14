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

xdesktop::shortcut { 'Code':
  shortcut_source => '/usr/share/applications/code.desktop',
  user            => $custom_user,
  position        => {
    provider => 'lxqt',
    x        => 139,
    y        => 768,
  },
  require         => [
    Package['desktop'],
    File['custom_user_desktop_folder'],
    File['desktop-items-0'],
    File_line['vscode-no-open-folder'],
  ],
}
