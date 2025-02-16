###
# Puppet Script for Tomcat 9 on Ubuntu 24.04
###

$tomcat_version = '9.0.99'
$tomcat_user = 'tomcat'
$tomcat_path = "/opt/tomcat-${tomcat_version}"
$tomcat_alias = '/opt/tomcat'

group { $tomcat_user:
  ensure          => present,
  system          => true,
  auth_membership => true,
  members         => [$default_user, $custom_user],
  require         => [
    Group['default_user'],
    Group['custom_user']
  ],
}

user { $tomcat_user:
  ensure     => present,
  gid        => $tomcat_user,
  comment    => 'Apache Tomcat Server system account',
  managehome => false,
  shell      => '/bin/false',
  system     => true,
  require    => Group[$tomcat_user],
}

file { $tomcat_path:
  ensure  => directory,
  replace => false,
  owner   => $tomcat_user,
  group   => $tomcat_user,
  require => User[$tomcat_user],
}

file { $tomcat_alias:
  ensure  => link,
  target  => $tomcat_path,
  replace => false,
  owner   => $tomcat_user,
  group   => $tomcat_user,
  require => File[$tomcat_path],
}

exec { 'install-tomcat':
  command => "curl https://dlcdn.apache.org/tomcat/tomcat-9/v${tomcat_version}/bin/apache-tomcat-${tomcat_version}.tar.gz | tar zxv -C ${tomcat_path} --strip-components=1",
  path    => '/usr/bin',
  user    => $tomcat_user,
  creates => "${tomcat_path}/bin/catalina.sh",
  require => [
    File[$tomcat_path],
    Package['curl'],
    Package['openjdk-11-jdk'],
  ],
} ~> exec { 'set-ROOT-mode':
  command => 'chmod 770 /opt/tomcat/webapps/ROOT',
  onlyif  => 'test -f /opt/tomcat/webapps/ROOT/index.php',
  path    => '/usr/bin',
}

file { 'set-webapps-mode':
  ensure  => directory,
  path    => "${tomcat_path}/webapps",
  owner   => $tomcat_user,
  group   => $tomcat_user,
  # Allow members of the group 'tomcat' to write to the folder
  # sets the sticky bit so that they can't delete or rename existing files
  # sets the setgid flag so that group ownership is inherited on new files/directories
  mode    => '3770',
  require => Exec['install-tomcat'],
}

file { '/var/run/tomcat':
  ensure => directory,
  owner  => $tomcat_user,
  group  => $tomcat_user,
  mode   => '0774',
}

$tomcat_service_unit = @("TOMCAT_SERVICE_UNIT_EOF"/L)
  [Unit]
  Description=Apache Tomcat Web Application Container
  After=network.target

  [Service]
  Type=forking
  User=${tomcat_user}
  Group=${tomcat_user}
  UMask=002
  Environment="JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64"
  Environment="_JAVA_OPTIONS="
  Environment="CATALINA_HOME=${tomcat_alias}"
  Environment="CATALINA_PID=/var/run/tomcat/tomcat.pid"
  Environment="CATALINA_OPTS=-Xms512M -Xmx6144M"
  ExecStart=${tomcat_alias}/bin/startup.sh
  ExecStop=${tomcat_alias}/bin/shutdown.sh

  [Install]
  WantedBy=multi-user.target
  | TOMCAT_SERVICE_UNIT_EOF

file { 'tomcat.service':
  ensure  => file,
  path    => '/etc/systemd/system/tomcat.service',
  content => $tomcat_service_unit,
  require => [
    User[$tomcat_user],
    Exec['install-tomcat'],
    File[$tomcat_alias],
  ],
} ~> exec { 'systemd-reload-tomcat':
  command => 'systemctl daemon-reload',
  path    => '/usr/bin',
  user    => 'root',
}

service { 'tomcat':
  ensure  => running,
  enable  => true,
  require => [
    File['/var/run/tomcat'],
    File['/etc/systemd/system/tomcat.service'],
    Exec['systemd-reload-tomcat'],
    Package['openjdk-11-jdk'],
  ],
}

$tomcat_service_sudoer = @("TOMCAT_SERVICE_SUDOER_EOF"/L)
%${tomcat_user} ALL=(ALL) NOPASSWD: /usr/bin/systemctl stop tomcat, /usr/bin/systemctl start tomcat, /usr/sbin/service tomcat stop, /usr/sbin/service tomcat start
  | TOMCAT_SERVICE_SUDOER_EOF

file { 'tomcat-service-sudoer':
  ensure  => file,
  path    => '/etc/sudoers.d/tomcat-service-sudoer',
  owner   => 'root',
  group   => 'root',
  mode    => '0440',
  content => $tomcat_service_sudoer,
  require => [
    Group[$tomcat_user],
    File['tomcat.service']
  ],
}
