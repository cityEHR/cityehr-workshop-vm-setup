###
# Puppet Script for cityEHR on Ubuntu 24.04
###

$cityehr_version = '1.8.0-SNAPSHOT'
$cityehr_war_url = 'https://openhealthinformatics.com/wp-content/resources/cityehr-webapp-${cityehr_version}.war'
$cityehr_war_path = '/opt/tomcat/webapps/cityehr.war'
$cityehr_quickstart = '2024-08-05_cityEHR_QuickStart.pdf'

$firefox_profile_id = 'ki59z67a'

exec { 'download-cityehr':
  command => "curl -L ${cityehr_war_url} -o ${cityehr_war_path}",
  path    => '/usr/bin',
  user    => 'tomcat',
  group   => 'tomcat',
  creates => $cityehr_war_path,
  require => [
    Package['file'],
    Package['curl'],
    Service['tomcat']
  ],
}

# Add a Desktop Shortcut to the cityEHR Documentation
exec { 'download-cityehr-logo':
  command => "wget -O /home/${custom_user}/.local/share/icons/cityehr-logo.png https://cityehr.github.io/cityehr-documentation/images/cityehr-logo.png",
  path    => '/usr/bin',
  creates => "/home/${custom_user}/.local/share/icons/cityehr-logo.png",
  user    => $custom_user,
  require => [
    File['local-icons'],
    Package['wget'],
  ],
}

$cityehr_documentation_desktop_shortcut =  @("CITYEHR_DOCUMENTATION_SHORTCUT_EOF"/L)
  [Desktop Entry]
  Version=1.0
  Name=cityEHR Documentation
  Exec=/usr/bin/google-chrome-stable https://cityehr.github.io/cityehr-documentation/
  StartupNotify=true
  Terminal=false
  Icon=/home/${custom_user}/.local/share/icons/cityehr-logo.png
  Type=Application
  | CITYEHR_DOCUMENTATION_SHORTCUT_EOF

file { 'cityehr-documentation-desktop-shortcut':
  ensure  => file,
  path    => "/home/${custom_user}/Desktop/cityehr-documentation.desktop",
  content => $cityehr_documentation_desktop_shortcut,
  owner   => $custom_user,
  group   => $custom_user,
  mode    => '0644',
  require => [
    Package['desktop'],
    File['custom_user_desktop_folder'],
    Package['google-chrome-stable'],
    Exec['download-cityehr-logo'],
  ],
}

exec { 'gvfs-trust-cityehr-documentation-desktop-shortcut':
  command     => "/usr/bin/dbus-launch gio set /home/${custom_user}/Desktop/cityehr-documentation.desktop metadata::trusted true",
  unless      => "/usr/bin/dbus-launch gio info --attributes=metadata::trusted /home/${custom_user}/Desktop/cityehr-documentation.desktop | /usr/bin/grep trusted",
  user        => $custom_user,
  environment => [
    'DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus',
  ],
  require     => File['cityehr-documentation-desktop-shortcut'],
}

# ini_setting { 'cityehr-documentation-desktop-shortcut-position':
#   ensure  => present,
#   path    => "/home/${custom_user}/.config/pcmanfm-qt/lxqt/desktop-items-0.conf",
#   section => 'cityehr-documentation.desktop',
#   setting => 'pos',
#   value   => '@Point(393 138)',
#   require => [
#     File['desktop-items-0'],
#     File['cityehr-documentation-desktop-shortcut'],
#   ],
# }

# Set homepage for cityEHR

file { "/home/${custom_user}/snap":
  ensure  => directory,
  owner   => $custom_user,
  group   => $custom_user,
  mode    => '0700',
  require => File['custom_user_home'],
}

file { "/home/${custom_user}/snap/firefox":
  ensure  => directory,
  owner   => $custom_user,
  group   => $custom_user,
  mode    => '0755',
  require => File["/home/${custom_user}/snap"],
}

file { "/home/${custom_user}/snap/firefox/common":
  ensure  => directory,
  owner   => $custom_user,
  group   => $custom_user,
  mode    => '0755',
  require => File["/home/${custom_user}/snap/firefox"],
}

file { "/home/${custom_user}/snap/firefox/common/.mozilla":
  ensure  => directory,
  owner   => $custom_user,
  group   => $custom_user,
  mode    => '0700',
  require => File["/home/${custom_user}/snap/firefox/common"],
}

file { "/home/${custom_user}/snap/firefox/common/.mozilla/firefox":
  ensure  => directory,
  owner   => $custom_user,
  group   => $custom_user,
  mode    => '0700',
  require => File["/home/${custom_user}/snap/firefox/common/.mozilla"],
}

file { "/home/${custom_user}/snap/firefox/common/.mozilla/firefox/profiles.ini":
  ensure  => file,
  owner   => $custom_user,
  group   => $custom_user,
  mode    => '0664',
  content => "[Profile0]
Name=default
IsRelative=1
Path=${firefox_profile_id}.default
Default=1

[General]
StartWithLastProfile=1
Version=2",
  require => [
    File["/home/${custom_user}/snap/firefox/common/.mozilla/firefox"],
    Exec['download-cityehr'],
    Package['firefox'],
  ],
}

file { "/home/${custom_user}/snap/firefox/common/.mozilla/firefox/${firefox_profile_id}.default":
  ensure  => directory,
  owner   => $custom_user,
  group   => $custom_user,
  mode    => '0700',
  require => File["/home/${custom_user}/snap/firefox/common/.mozilla/firefox"],
}

file { "/home/${custom_user}/snap/firefox/common/.mozilla/firefox/${firefox_profile_id}.default/prefs.js":
  ensure  => file,
  owner   => $custom_user,
  group   => $custom_user,
  mode    => '0600',
  require => File["/home/${custom_user}/snap/firefox/common/.mozilla/firefox/${firefox_profile_id}.default"],
}

file_line { 'firefox-home-page':
  ensure  => present,
  path    => "/home/${custom_user}/snap/firefox/common/.mozilla/firefox/${firefox_profile_id}.default/prefs.js",
  line    => 'user_pref("browser.startup.homepage", "http://localhost:8080/cityehr");',
  match   => '^user_pref\("browser\.startup\.homepage"',
  require => [
    File["/home/${custom_user}/snap/firefox/common/.mozilla/firefox/${firefox_profile_id}.default/prefs.js"],
    Exec['download-cityehr'],
    Package['firefox'],
  ],
}
