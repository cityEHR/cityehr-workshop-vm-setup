###
# Puppet Script for extra Desktop Shortcuts on Ubuntu 24.04
###

file { 'dot-local':
  ensure  => directory,
  path    => "/home/${custom_user}/.local",
  owner   => $custom_user,
  group   => $custom_user,
  mode    => '0700',
  require => Package['desktop'],
}

file { 'dot-local-share':
  ensure  => directory,
  path    => "/home/${custom_user}/.local/share",
  owner   => $custom_user,
  group   => $custom_user,
  mode    => '0700',
  require => [
    Package['desktop'],
    File['dot-local'],
  ],
}

file { 'local-icons':
  ensure  => directory,
  path    => "/home/${custom_user}/.local/share/icons",
  owner   => $custom_user,
  group   => $custom_user,
  mode    => '0755',
  require => [
    Package['desktop'],
    File['dot-local-share'],
  ],
}

exec { 'download-eb-favicon-logo':
  command => "wget -O /home/${custom_user}/.local/share/icons/eb-favicon-logo.svg https://evolvedbinary.com/images/icons/shape-icon.svg",
  path    => '/usr/bin',
  creates => "/home/${custom_user}/.local/share/icons/eb-favicon-logo.svg",
  user    => $custom_user,
  require => [
    File['local-icons'],
    Package['wget'],
  ],
}

xdesktop::shortcut { 'Evolved Binary':
  application_path => '/usr/bin/google-chrome-stable https://www.evolvedbinary.com',
  application_icon => "/home/${custom_user}/.local/share/icons/eb-favicon-logo.svg",
  startup_notify   => true,
  user             => $custom_user,
  position         => {
    provider => 'lxqt',
    x        => 393,
    y        => 264,
  },
  require          => [
    Package['desktop'],
    Package['google-chrome-stable'],
    File['custom_user_desktop_folder'],
    File['desktop-items-0'],
    Exec['download-eb-favicon-logo'],
  ],
}

exec { 'download-ohi-logo':
  command => "wget -O /home/${custom_user}/.local/share/icons/ohi-logo.png https://openhealthinformatics.com/wp-content/uploads/2024/05/cropped-logo-150x150.png",
  path    => '/usr/bin',
  creates => "/home/${custom_user}/.local/share/icons/ohi-logo.png",
  user    => $custom_user,
  require => [
    File['local-icons'],
    Package['wget'],
  ],
}

xdesktop::shortcut { 'Open Health Informatics':
  application_path => '/usr/bin/google-chrome-stable https://openhealthinformatics.com',
  application_icon => "/home/${custom_user}/.local/share/icons/ohi-logo.png",
  startup_notify   => true,
  user             => $custom_user,
  position         => {
    provider => 'lxqt',
    x        => 393,
    y        => 138,
  },
  require          => [
    Package['desktop'],
    Package['google-chrome-stable'],
    File['custom_user_desktop_folder'],
    File['desktop-items-0'],
    Exec['download-ohi-logo'],
  ],
}
