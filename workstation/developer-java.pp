###
# Puppet Script for a Java Developer Environment on Ubuntu 24.04
###

include apt

$maven_version = '3.9.9'

# Install OpenJDK 11
package { 'openjdk-11-jdk':
  ensure  => installed,
}

package { 'openjdk-11-jre':
  ensure  => installed,
  require => Package['openjdk-11-jdk'],
}

# Install Adoptium Temurin JDK 17 (oXygen XML Editor only support Oracle or Temurin JDKs)
apt::source { 'adoptium':
  location => 'https://packages.adoptium.net/artifactory/deb',
  release  => 'noble',
  repos    => 'main',
  comment  => 'adoptium',
  key      => {
    id     => '3B04D753C9050D9A5D343F39843C48A565F8F04B',
    name   => 'adoptium.gpg.key',
    source => 'https://packages.adoptium.net/artifactory/api/gpg/key/public',
  },
  notify   => Exec['apt_update'],
}

package { 'temurin-17-jdk':
  ensure  => installed,
  require => [
    Apt::Source['adoptium'],
    Exec['apt_update'],
    Package['openjdk-11-jdk'],
  ],
}
~> exec { 'update-java-alternatives':
  command => '/usr/sbin/update-java-alternatives --set temurin-17-jdk-amd64',
  user    => 'root',
  require => Package['temurin-17-jdk'],
}

file_line { 'JAVA_HOME':
  ensure  => present,
  path    => '/etc/environment',
  line    => 'JAVA_HOME=/usr/lib/jvm/temurin-17-jdk-amd64',
  match   => '^JAVA_HOME\=',
  require => Package['temurin-17-jdk'],
}

# Install JavaFX 17
exec { 'download-openjfx17':
  command => 'wget https://download2.gluonhq.com/openjfx/17.0.12/openjfx-17.0.12_linux-x64_bin-jmods.zip -O /tmp/openjdk-jmods.zip',
  path    => '/usr/bin',
  user    => 'root',
  creates => '/usr/lib/jvm/javafx-jmods-17.0.12',
  require => Package['wget'],
}
~> exec { 'extract-openjfx17':
  command => 'unzip /tmp/openjdk-jmods.zip -d /usr/lib/jvm',
  path    => '/usr/bin',
  user    => 'root',
  creates => '/usr/lib/jvm/javafx-jmods-17.0.12',
  require => Package['unzip'],
}
~> file_line { '_JAVA_OPTIONS':
  ensure => present,
  path   => '/etc/environment',
  line   => '_JAVA_OPTIONS="--module-path=/usr/lib/jvm/javafx-jmods-17.0.12 --add-modules=ALL-MODULE-PATH"',
  match  => '^_JAVA_OPTIONS\=',
}

exec { 'install-maven':
  command => "curl -L https://archive.apache.org/dist/maven/maven-3/${maven_version}/binaries/apache-maven-${maven_version}-bin.tar.gz | tar zxv -C /opt",
  path    => '/usr/bin',
  user    => 'root',
  creates => "/opt/apache-maven-${maven_version}",
  require => Package['curl'],
}

file { '/opt/maven':
  ensure  => link,
  target  => "/opt/apache-maven-${maven_version}",
  replace => false,
  owner   => 'root',
  group   => 'root',
  require => Exec['install-maven'],
}

file_line { 'MAVEN_HOME':
  ensure  => present,
  path    => '/etc/environment',
  line    => 'MAVEN_HOME=/opt/maven',
  match   => '^MAVEN_HOME\=',
  require => File['/opt/maven'],
}

file_line { 'PATH':
  ensure  => present,
  path    => '/etc/environment',
  line    => 'PATH=/opt/maven/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin',
  match   => '^PATH\=',
  require => File['/opt/maven'],
}
