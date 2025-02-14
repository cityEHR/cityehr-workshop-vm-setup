###
# Puppet Script for Mirth Connect on Ubuntu 24.04
###

$mirth_connect_version = '4.5.1.b332'
$mirth_connect_user = 'mirth-connect'
$mirth_connect_path = "/opt/mirth-connect-${mirth_connect_version}"
$mirth_connect_alias = '/opt/mirth-connect'
$mirth_connect_http_port = '8090'
$mirth_connect_https_port = '8553'

group { $mirth_connect_user:
  ensure          => present,
  system          => true,
  auth_membership => false,
  members         => [$custom_user],
}

user { $mirth_connect_user:
  ensure     => present,
  gid        => $mirth_connect_user,
  comment    => 'Mirth Connect system account',
  managehome => false,
  shell      => '/bin/false',
  system     => true,
  require    => Group[$mirth_connect_user],
}

file { $mirth_connect_path:
  ensure  => directory,
  replace => false,
  owner   => $mirth_connect_user,
  group   => $mirth_connect_user,
  require => User[$mirth_connect_user],
}

file { $mirth_connect_alias:
  ensure  => link,
  target  => $mirth_connect_path,
  replace => false,
  owner   => $mirth_connect_user,
  group   => $mirth_connect_user,
  require => File[$mirth_connect_path],
}

exec { 'install-mirth-connect':
  command => "curl https://s3.amazonaws.com/downloads.mirthcorp.com/connect/${mirth_connect_version}/mirthconnect-${mirth_connect_version}-unix.tar.gz | tar zxv -C ${mirth_connect_path} --strip-components=1",
  path    => '/usr/bin',
  user    => $mirth_connect_user,
  creates => "${mirth_connect_path}/mcserver",
  require => [
    File[$mirth_connect_path],
    Package['curl'],
    Package['temurin-17-jdk'],
  ],
}

file_line { 'mirth-connect-http-port':
  ensure  => present,
  path    => "${mirth_connect_path}/conf/mirth.properties",
  line    => "http.port = ${mirth_connect_http_port}",
  match   => '^http.port \= ',
  require => Exec['install-mirth-connect'],
}

file_line { 'mirth-connect-https-port':
  ensure  => present,
  path    => "${mirth_connect_path}/conf/mirth.properties",
  line    => "https.port = ${mirth_connect_https_port}",
  match   => '^https.port \= ',
  require => Exec['install-mirth-connect'],
}

$mirth_connect_service_unit = @("MIRTH_CONNECT_SERVICE_UNIT_EOF"/L)
  [Unit]
  Description=Mirth Connect
  After=network.target

  [Service]
  Type=forking
  User=${mirth_connect_user}
  Group=${mirth_connect_user}
  ExecStart=${mirth_connect_alias}/mcservice start
  ExecStop=${mirth_connect_alias}/mcservice stop
  ExecReload=${mirth_connect_alias}/mcservice force-reload

  [Install]
  WantedBy=multi-user.target
  | MIRTH_CONNECT_SERVICE_UNIT_EOF

file { '/etc/systemd/system/mirth-connect.service':
  ensure  => file,
  content => $mirth_connect_service_unit,
  require => [
    User[$mirth_connect_user],
    Exec['install-mirth-connect'],
    File[$mirth_connect_alias],
  ],
} ~> exec { 'systemd-reload-mirth-connect':
  command => 'systemctl daemon-reload',
  path    => '/usr/bin',
  user    => 'root',
}

service { 'mirth-connect':
  ensure  => running,
  enable  => true,
  require => [
    File['/etc/systemd/system/mirth-connect.service'],
    Exec['systemd-reload-mirth-connect'],
    Package['temurin-17-jdk'],
  ],
}
