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

xdesktop::shortcut { 'DBeaver CE':
  shortcut_source => '/usr/share/applications/dbeaver-ce.desktop',
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
    Package['dbeaver-ce'],
  ],
}
