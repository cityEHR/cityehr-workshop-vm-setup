###
# Puppet Script for oXygen XML Editor on Ubuntu 24.04
###

$oxygen_version = '26.0'

$oxygen_license_xml = @(OXYGEN_LICENSE_XML_EOF:xml/L)
  <?xml version="1.0" encoding="UTF-8"?>
  <serialized xml:space="preserve">
    <serializableOrderedMap>
      <entry>
        <String>license.26</String>
        <String>------START-LICENSE-KEY------

Registration_Name=sysops @ evolvedbinary . com

Company=Evolved-Binary

Category=Enterprise

Component=XML-Editor, XSLT-Debugger, Saxon-SA

Version=26

Number_of_Licenses=1

Date=09-15-2024

Trial=31

SGN=MCwCFHzStSY/uhwcbe9Dsry/qUvy2rLPAhQIZ0J/y6ypZQvecApCqdMu7DXu3A\=\=

-------END-LICENSE-KEY-------</String>
      </entry>
    </serializableOrderedMap>
  </serialized>
  | OXYGEN_LICENSE_XML_EOF

file { "/opt/oxygen-${oxygen_version}":
  ensure  => directory,
  replace => false,
  owner   => 'root',
  group   => 'root',
}

exec { 'install-oxygen':
  command => "curl https://mirror.oxygenxml.com/InstData/Editor/All/oxygen.tar.gz | tar zxv -C /opt/oxygen-${oxygen_version} --strip-components=1",
  path    => '/usr/bin',
  user    => 'root',
  creates => "/opt/oxygen-${oxygen_version}/oxygen.sh",
  require => [
    File["/opt/oxygen-${oxygen_version}"],
    Package['curl']
  ],
}

file { '/opt/oxygen':
  ensure  => link,
  target  => "/opt/oxygen-${oxygen_version}",
  replace => false,
  owner   => 'root',
  group   => 'root',
  require => File["/opt/oxygen-${oxygen_version}"],
}

xdesktop::shortcut { 'Oxygen XML Editor':
  application_path => '/opt/oxygen/oxygen.sh',
  application_icon => '/opt/oxygen/Oxygen128.png',
  user             => $custom_user,
  position         => {
    provider => 'lxqt',
    x        => 139,
    y        => 264,
  },
  require          => [
    Package['desktop'],
    File['custom_user_desktop_folder'],
    File['desktop-items-0'],
    File['/opt/oxygen'],
  ],
}

# oXygen License file
file { 'oxygen-user-settings-path':
  ensure  => directory,
  path    => "/home/${custom_user}/.com.oxygenxml",
  replace => false,
  owner   => $custom_user,
  group   => $custom_user,
  mode    => '0775',
}

file { 'oxygen-license':
  ensure  => file,
  path    => "/home/${custom_user}/.com.oxygenxml/license.xml",
  replace => false,
  owner   => $custom_user,
  group   => $custom_user,
  mode    => '0664',
  content => $oxygen_license_xml,
  require => File['oxygen-user-settings-path'],
}
