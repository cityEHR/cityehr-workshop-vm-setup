###
# Puppet Script for LibreOffice on Ubuntu 24.04
###

package { 'libreoffice':
  ensure  => installed,
  require => Package['desktop'],
}

xdesktop::shortcut { 'LibreOffice Writer':
  shortcut_source => '/usr/share/applications/libreoffice-writer.desktop',
  user            => $custom_user,
  position        => {
    provider => 'lxqt',
    x        => 139,
    y        => 264,
  },
  require         => [
    Package['desktop'],
    File['custom_user_desktop_folder'],
    File['desktop-items-0'],
    Package['libreoffice'],
  ],
}

xdesktop::shortcut { 'LibreOffice Calc':
  shortcut_source => '/usr/share/applications/libreoffice-calc.desktop',
  user            => $custom_user,
  position        => {
    provider => 'lxqt',
    x        => 139,
    y        => 390,
  },
  require         => [
    Package['desktop'],
    File['custom_user_desktop_folder'],
    File['desktop-items-0'],
    Package['libreoffice'],
  ],
}
