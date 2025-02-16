###
# Puppet Script for MySQL Workbench on Ubuntu 22.04
###

$mysql_workbench_community_version = '8.0.41-1ubuntu24.04_amd64'

exec { 'download-mysql-workbench-community-deb':
  command => "/usr/bin/curl -L https://dev.mysql.com/get/Downloads/MySQLGUITools/mysql-workbench-community_${mysql_workbench_community_version}.deb -o /tmp/mysql-workbench-community_${mysql_workbench_community_version}.deb",
  unless  => '/usr/bin/dpkg -s mysql-workbench-community',
  require => Package['curl'],
}

package { 'mysql-workbench-community':
  ensure  => installed,
  source  => "/tmp/mysql-workbench-community_${mysql_workbench_community_version}.deb",
  require => [
    Package['desktop'],
    Exec['download-mysql-workbench-community-deb'],
  ],
}

xdesktop::shortcut { 'MySQL Workbench':
  shortcut_source => '/usr/share/applications/mysql-workbench.desktop',
  user            => $custom_user,
  position        => {
    provider => 'lxqt',
    x        => 139,
    y        => 642,
  },
  require         => [
    Package['desktop'],
    File['custom_user_desktop_folder'],
    File['desktop-items-0'],
    Package['mysql-workbench-community'],
  ],
}
