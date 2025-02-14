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

xdesktop::shortcut { 'Gantt Project':
  shortcut_source => '/usr/share/applications/ganttproject.desktop',
  user            => $custom_user,
  position        => {
    provider => 'lxqt',
    x        => 266,
    y        => 516,
  },
  require         => [
    Package['desktop'],
    File['custom_user_desktop_folder'],
    File['desktop-items-0'],
    Package['ganttproject'],
  ],
}
