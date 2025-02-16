###
# Puppet Script for Inkscape on Ubuntu 24.04
###

package { 'inkscape':
  ensure  => installed,
  require => Package['desktop'],
}

xdesktop::shortcut { 'Inkscape':
  shortcut_source => '/usr/share/applications/org.inkscape.Inkscape.desktop',
  user            => $custom_user,
  position        => {
    provider => 'lxqt',
    x        => 266,
    y        => 138,
  },
  require         => [
    Package['desktop'],
    File['custom_user_desktop_folder'],
    File['desktop-items-0'],
    Package['inkscape'],
  ],
}
