###
# Puppet Script for GanttProject on Ubuntu 22.04
###

exec { 'download-ganttproject-deb':
  command => '/usr/bin/curl -L https://www.ganttproject.biz/dl/3.3.3309/lin -o /tmp/ganttproject.deb',
  unless  => '/usr/bin/dpkg -s ganttproject',
  require => Package['curl'],
}

package { 'ganttproject':
  ensure  => installed,
  source  => '/tmp/ganttproject.deb',
  require => [
    Package['desktop'],
    Package['temurin-17-jdk'],
    Exec['download-ganttproject-deb'],
  ],
}

# Add Desktop shortcut
file { 'ganttproject-shortcut':
  ensure  => file,
  path    => "/home/${custom_user}/Desktop/ganttproject.desktop",
  source  => '/usr/share/applications/ganttproject.desktop',
  owner   => $custom_user,
  group   => $custom_user,
  mode    => '0644',
  require => [
    Package['desktop'],
    File['custom_user_desktop_folder'],
    Package['ganttproject'],
  ],
}

exec { 'gvfs-trust-ganttproject-shortcut':
  command     => "/usr/bin/dbus-launch gio set /home/${custom_user}/Desktop/ganttproject.desktop metadata::trusted true",
  unless      => "/usr/bin/dbus-launch gio info --attributes=metadata::trusted /home/${custom_user}/Desktop/ganttproject.desktop | /usr/bin/grep trusted",
  user        => $custom_user,
  environment => [
    'DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus',
  ],
  require     => File['ganttproject-shortcut'],
}

ini_setting { 'ganttproject-shortcut-position':
  ensure  => present,
  path    => "/home/${custom_user}/.config/pcmanfm-qt/lxqt/desktop-items-0.conf",
  section => 'ganttproject.desktop',
  setting => 'pos',
  value   => '@Point(266 516)',
  require => [
    File['desktop-items-0'],
    File['ganttproject-shortcut'],
  ],
}
