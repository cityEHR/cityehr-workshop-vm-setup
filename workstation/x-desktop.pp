###
# Puppet Script for a Desktop Developer Environment using LXQT on Ubuntu 24.04
###

$desktop_background_image = "/home/${custom_user}/Pictures/cityehrwork-desktop-background.png"

file { 'disable-screensaver':
  ensure  => file,
  path    => "/home/${custom_user}/.xscreensaver",
  replace => false,
  mode    => '0664',
  content => 'mode:    off',
}

file_line { 'disable-screensaver':
  ensure  => present,
  path    => "/home/${custom_user}/.xscreensaver",
  line    => 'mode:    off',
  match   => '^mode:',
  require => File['disable-screensaver'],
}

package { 'desktop':
  ensure  => installed,
  name    => 'lubuntu-desktop',
  require => File_line['disable-screensaver'],
}

ini_setting { 'lxqt-session-userfile':
  ensure  => present,
  path    => "/home/${custom_user}/.config/lxqt/session.conf",
  section => 'General',
  setting => '__userfile__',
  value   => 'true',
  require => Package['desktop'],
}

ini_setting { 'lxqt-session-window-manager':
  ensure  => present,
  path    => "/home/${custom_user}/.config/lxqt/session.conf",
  section => 'General',
  setting => 'window_manager',
  value   => 'xfwm4',
  require => Package['desktop'],
}

# Workaround for https://bugs.launchpad.net/ubuntu/+source/lubuntu-default-settings/+bug/1708200
file { 'xterm':
  ensure  => link,
  path    => '/usr/bin/xterm',
  target  => '/usr/bin/qterminal',
  require => Package['desktop'],
}

file { 'custom_user_desktop_folder':
  ensure  => directory,
  path    => "/home/${custom_user}/Desktop",
  replace => false,
  owner   => $custom_user,
  group   => $custom_user,
  mode    => '0775',
  require => [
    Package['desktop'],
    File['custom_user_home'],
  ],
}

file { "/home/${custom_user}/Pictures":
  ensure => directory,
  owner  => $custom_user,
  group  => $custom_user,
  mode   => '0755',
}

exec { 'download-desktop-background':
  command => "curl https://static.evolvedbinary.com/cityehr/cityehrwork-desktop-background.png -o ${desktop_background_image}",
  path    => '/usr/bin',
  user    => $custom_user,
  creates => $desktop_background_image,
  require => [
    File["/home/${custom_user}/Pictures"],
    File['custom_user_desktop_folder'],
  ],
}

file { "/home/${custom_user}/.config/pcmanfm-qt":
  ensure => directory,
  owner  => $custom_user,
  group  => $custom_user,
  mode   => '0775',
}

file { "/home/${custom_user}/.config/pcmanfm-qt/lxqt":
  ensure  => directory,
  owner   => $custom_user,
  group   => $custom_user,
  mode    => '0775',
  require => File["/home/${custom_user}/.config/pcmanfm-qt"],
}

file { 'settings.conf':
  ensure  => file,
  path    => "/home/${custom_user}/.config/pcmanfm-qt/lxqt/settings.conf",
  owner   => $custom_user,
  group   => $custom_user,
  mode    => '0664',
  require => File["/home/${custom_user}/.config/pcmanfm-qt/lxqt"],
}

ini_setting { 'desktop_background_image':
  ensure  => present,
  path    => "/home/${custom_user}/.config/pcmanfm-qt/lxqt/settings.conf",
  section => 'Desktop',
  setting => 'Wallpaper',
  value   => $desktop_background_image,
  require => [
    Package['desktop'],
    File['settings.conf'],
    Exec['download-desktop-background'],
  ],
}

ini_setting { 'desktop_background_mode':
  ensure  => present,
  path    => "/home/${custom_user}/.config/pcmanfm-qt/lxqt/settings.conf",
  section => 'Desktop',
  setting => 'WallpaperMode',
  value   => 'fit',
  require => [
    Package['desktop'],
    File['settings.conf'],
    Exec['download-desktop-background'],
  ],
}

ini_setting { 'desktop_background_color':
  ensure  => present,
  path    => "/home/${custom_user}/.config/pcmanfm-qt/lxqt/settings.conf",
  section => 'Desktop',
  setting => 'BgColor',
  value   => '#f8e5bd',
  require => [
    Package['desktop'],
    File['settings.conf'],
    Exec['download-desktop-background'],
  ],
}

$computer_desktop_shortcut = @("COMPUTER_DESKTOP_ENTRY_EOF"/L)
  [Desktop Entry]
  Type=Application
  Exec=pcmanfm-qt computer:///
  Icon=computer
  Name=Computer
  | COMPUTER_DESKTOP_ENTRY_EOF

file { 'computer-desktop-shortcut':
  ensure  => file,
  path    => "/home/${custom_user}/Desktop/computer.desktop",
  content => $computer_desktop_shortcut,
  owner   => $custom_user,
  group   => $custom_user,
  mode    => '0644',
  require => [
    Package['desktop'],
    File['custom_user_desktop_folder'],
  ],
}

exec { 'gvfs-trust-computer-desktop-shortcut':
  command     => "/usr/bin/dbus-launch gio set /home/${custom_user}/Desktop/computer.desktop metadata::trusted true",
  unless      => "/usr/bin/dbus-launch gio info --attributes=metadata::trusted /home/${custom_user}/Desktop/computer.desktop | /usr/bin/grep trusted",
  user        => $custom_user,
  environment => [
    'DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus',
  ],
  require     => File['computer-desktop-shortcut'],
}

$user_home_desktop_shortcut = @("USER_HOME_DESKTOP_ENTRY_EOF"/L)
  [Desktop Entry]
  Type=Application
  Exec=pcmanfm-qt /home/ubuntu
  Icon=user-home
  Name=ubuntu
  | USER_HOME_DESKTOP_ENTRY_EOF

file { 'user-home-desktop-shortcut':
  ensure  => file,
  path    => "/home/${custom_user}/Desktop/user-home.desktop",
  content => $user_home_desktop_shortcut,
  owner   => $custom_user,
  group   => $custom_user,
  mode    => '0644',
  require => [
    Package['desktop'],
    File['custom_user_desktop_folder'],
  ],
}

exec { 'gvfs-trust-user-home-desktop-shortcut':
  command     => "/usr/bin/dbus-launch gio set /home/${custom_user}/Desktop/user-home.desktop metadata::trusted true",
  unless      => "/usr/bin/dbus-launch gio info --attributes=metadata::trusted /home/${custom_user}/Desktop/user-home.desktop | /usr/bin/grep trusted",
  user        => $custom_user,
  environment => [
    'DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus',
  ],
  require     => File['user-home-desktop-shortcut'],
}

$network_desktop_shortcut = @("NETWORK_DESKTOP_ENTRY_EOF"/L)
  [Desktop Entry]
  Type=Application
  Exec=pcmanfm-qt network:///
  Icon=folder-network
  Name=Network
  | NETWORK_DESKTOP_ENTRY_EOF

file { 'network-desktop-shortcut':
  ensure  => file,
  path    => "/home/${custom_user}/Desktop/network.desktop",
  content => $network_desktop_shortcut,
  owner   => $custom_user,
  group   => $custom_user,
  mode    => '0644',
  require => [
    Package['desktop'],
    File['custom_user_desktop_folder'],
  ],
}

exec { 'gvfs-trust-network-desktop-shortcut':
  command     => "/usr/bin/dbus-launch gio set /home/${custom_user}/Desktop/network.desktop metadata::trusted true",
  unless      => "/usr/bin/dbus-launch gio info --attributes=metadata::trusted /home/${custom_user}/Desktop/network.desktop | /usr/bin/grep trusted",
  user        => $custom_user,
  environment => [
    'DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus',
  ],
  require     => File['network-desktop-shortcut'],
}

$trash_can_desktop_shortcut = @("NETWORK_DESKTOP_ENTRY_EOF"/L)
  [Desktop Entry]
  Type=Application
  Exec=pcmanfm-qt trash:///
  Icon=user-trash
  Name=Trash (Empty)
  | NETWORK_DESKTOP_ENTRY_EOF

file { 'trash-can-desktop-shortcut':
  ensure  => file,
  path    => "/home/${custom_user}/Desktop/trash-can.desktop",
  content => $trash_can_desktop_shortcut,
  owner   => $custom_user,
  group   => $custom_user,
  mode    => '0644',
  require => [
    Package['desktop'],
    File['custom_user_desktop_folder'],
  ],
}

exec { 'gvfs-trust-trash-can-desktop-shortcut':
  command     => "/usr/bin/dbus-launch gio set /home/${custom_user}/Desktop/trash-can.desktop metadata::trusted true",
  unless      => "/usr/bin/dbus-launch gio info --attributes=metadata::trusted /home/${custom_user}/Desktop/trash-can.desktop | /usr/bin/grep trusted",
  user        => $custom_user,
  environment => [
    'DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus',
  ],
  require     => File['trash-can-desktop-shortcut'],
}

file_line { 'simplify-qterminalname-1':
  ensure  => present,
  path    => '/usr/share/applications/qterminal.desktop',
  line    => 'Name=Terminal',
  match   => '^Name\=QTerminal',
  require => Package['desktop'],
}

file_line { 'simplify-qterminalname-2':
  ensure  => present,
  path    => '/usr/share/applications/qterminal.desktop',
  line    => 'Name[en_GB]=Terminal',
  match   => '^Name[en_GB]\=Qterminal',
  require => Package['desktop'],
}

file { 'qterminal-desktop-shortcut':
  ensure  => file,
  path    => "/home/${custom_user}/Desktop/qterminal.desktop",
  source  => '/usr/share/applications/qterminal.desktop',
  owner   => $custom_user,
  group   => $custom_user,
  mode    => '0644',
  require => [
    Package['desktop'],
    File['custom_user_desktop_folder'],
    File_line['simplify-qterminalname-1'],
    File_line['simplify-qterminalname-2'],
  ],
}

exec { 'gvfs-trust-qterminal-desktop-shortcut':
  command     => "/usr/bin/dbus-launch gio set /home/${custom_user}/Desktop/qterminal.desktop metadata::trusted true",
  unless      => "/usr/bin/dbus-launch gio info --attributes=metadata::trusted /home/${custom_user}/Desktop/qterminal.desktop | /usr/bin/grep trusted",
  user        => $custom_user,
  environment => [
    'DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus',
  ],
  require     => File['qterminal-desktop-shortcut'],
}

file_line { 'simplify-pcmanfm-qt-name':
  ensure  => present,
  path    => '/usr/share/applications/pcmanfm-qt.desktop',
  line    => 'Name=File Manager',
  match   => '^Name\=',
  require => Package['desktop'],
}

file { 'pcmanfm-qt-desktop-shortcut':
  ensure  => file,
  path    => "/home/${custom_user}/Desktop/pcmanfm-qt.desktop",
  source  => '/usr/share/applications/pcmanfm-qt.desktop',
  owner   => $custom_user,
  group   => $custom_user,
  mode    => '0644',
  require => [
    Package['desktop'],
    File['custom_user_desktop_folder'],
    File_line['simplify-pcmanfm-qt-name'],
  ],
}

exec { 'gvfs-trust-pcmanfm-qt-desktop-shortcut':
  command     => "/usr/bin/dbus-launch gio set /home/${custom_user}/Desktop/pcmanfm-qt.desktop metadata::trusted true",
  unless      => "/usr/bin/dbus-launch gio info --attributes=metadata::trusted /home/${custom_user}/Desktop/pcmanfm-qt.desktop | /usr/bin/grep trusted",
  user        => $custom_user,
  environment => [
    'DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus',
  ],
  require     => File['pcmanfm-qt-desktop-shortcut'],
}

file_line { 'simplify-lxqt-archiver-name':
  ensure  => present,
  path    => '/usr/share/applications/lxqt-archiver.desktop',
  line    => 'Name=File Archiver',
  match   => '^Name\=',
  require => Package['desktop'],
}

file { 'lxqt-archiver-desktop-shortcut':
  ensure  => file,
  path    => "/home/${custom_user}/Desktop/lxqt-archiver.desktop",
  source  => '/usr/share/applications/lxqt-archiver.desktop',
  owner   => $custom_user,
  group   => $custom_user,
  mode    => '0644',
  require => [
    Package['desktop'],
    File['custom_user_desktop_folder'],
    File_line['simplify-lxqt-archiver-name'],
  ],
}

exec { 'gvfs-trust-lxqt-archiver-desktop-shortcut':
  command     => "/usr/bin/dbus-launch gio set /home/${custom_user}/Desktop/lxqt-archiver.desktop metadata::trusted true",
  unless      => "/usr/bin/dbus-launch gio info --attributes=metadata::trusted /home/${custom_user}/Desktop/lxqt-archiver.desktop | /usr/bin/grep trusted",
  user        => $custom_user,
  environment => [
    'DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus',
  ],
  require     => File['lxqt-archiver-desktop-shortcut'],
}

file { 'desktop-items-0':
  ensure  => file,
  path    => "/home/${custom_user}/.config/pcmanfm-qt/lxqt/desktop-items-0.conf",
  owner   => $custom_user,
  group   => $custom_user,
  mode    => '0644',
  require => File["/home/${custom_user}/.config/pcmanfm-qt/lxqt"],
}

# Position the Desktop icons
inifile::create_ini_settings( {
    'computer.desktop'      => { 'pos' => '@Point(12 12)' },
    'user-home.desktop'     => { 'pos' => '@Point(12 138)' },
    'network.desktop'       => { 'pos' => '@Point(12 264)' },
    'trash-can.desktop'     => { 'pos' => '@Point(12 390)' },
    'pcmanfm-qt.desktop'    => { 'pos' => '@Point(12 516)' },
    'lxqt-archiver.desktop' => { 'pos' => '@Point(12 642)' },
    'qterminal.desktop'     => { 'pos' => '@Point(12 768)' },
  }, {
    ensure => present,
    path => "/home/${custom_user}/.config/pcmanfm-qt/lxqt/desktop-items-0.conf",
    require => [
      Package['desktop'],
      File['desktop-items-0'],
      File['pcmanfm-qt-desktop-shortcut'],
      File['lxqt-archiver-desktop-shortcut'],
      File['qterminal-desktop-shortcut'],
    ]
  }
)
