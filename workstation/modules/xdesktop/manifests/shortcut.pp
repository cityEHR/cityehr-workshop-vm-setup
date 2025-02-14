# Create a desktop shortcut icon.
#
# @param application_path [String]
#   The path to the application binary. NOTE: Either this or shortcut_source must be provided.
# @param shortcut_source [String]
#   The source of an existing shortcut definition to copy. NOTE: Either this or application_path must be provided
# @param application_name [String]
#   The name of the application that the shortcut is for.
# @param application_icon [String]
#   The icon to use for the application.
# @param startup_notify [Boolean]
#   The value of StartupNotify` in the shortcut file. Defaults to 'false'.
# @param user [String]
#   The name of the user to create the desktop shortcut for. Defaults to the current user.
# @param owner [String]
#   The name of the user that owns the desktop shortcut. Defaults to the user.
# @param group [String]
#   The name of the group that owns the desktop shortcut. Defaults to the user.
# @param position [xdesktop::Position]
#   A hash describing where the shortcut should be positioned on the desktop.
#   For example `position => { provider => 'lxqt', x => 266, y => 642 }`.
#
define xdesktop::shortcut (
  Variant[String, Undef] $application_path = undef,
  Variant[String, Undef] $shortcut_source = undef,
  String $application_name = $title,
  Variant[String, Undef] $application_icon = undef,
  Boolean $startup_notify = false,
  String $user = $identity['user'],
  String $owner = $user,
  String $group = $user,
  Variant[Position, Undef] $position = undef,
) {
  include xdesktop

  $user_home = "${xdesktop::home}/${user}"
  $desktop = "${user_home}/Desktop"

  $shortcut_filename = join([regsubst(downcase($application_name), /\s+/, '-', 'G'), '.desktop'])

  if $shortcut_source != undef {
    file { "${title}@shortcut":
      ensure => file,
      path   => "${desktop}/${shortcut_filename}",
      source => $shortcut_source,
      owner  => $owner,
      group  => $group,
      mode   => '0640',
    }
  } else {
    $desktop_entry_base = @("DESKTOP_ENTRY_EOF"/L)
      [Desktop Entry]
      Version=1.0
      Type=Application
      Name=${application_name}
      Exec=${application_path}
      Terminal=false
      StartupNotify=${startup_notify}
      GenericName=${application_name}
      | DESKTOP_ENTRY_EOF

    if $application_icon {
      $desktop_entry_icon = "Icon=${application_icon}"
      $desktop_entry = join([$desktop_entry_base, $desktop_entry_icon])
    } else {
      $desktop_entry = $desktop_entry_base
    }

    file { "${title}@shortcut":
      ensure  => file,
      path    => "${desktop}/${shortcut_filename}",
      owner   => $owner,
      group   => $group,
      mode    => '0640',
      content => $desktop_entry,
    }
  }

  exec { "${title}@gvfs-trust-shortcut":
    command     => "/usr/bin/dbus-launch gio set ${desktop}/${shortcut_filename} metadata::trusted true",
    unless      => "/usr/bin/dbus-launch gio info --attributes=metadata::trusted ${desktop}/${shortcut_filename} | /usr/bin/grep trusted",
    user        => $owner,
    environment => [
      'DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus',
    ],
    require     => File["${title}@shortcut"],
  }

  if $position {
    if ($position['provider'] == 'lxqt') {
      # file { "${title}@${user_home}/.config/pcmanfm-qt":
      #   ensure  => directory,
      #   path    => "${user_home}/.config/pcmanfm-qt",
      #   replace => false,
      #   owner   => $user,
      #   group   => $group,
      #   mode    => '0770',
      # }

      # file { "${title}@${user_home}/.config/pcmanfm-qt/lxqt":
      #   ensure  => directory,
      #   path    => "${user_home}/.config/pcmanfm-qt/lxqt",
      #   replace => false,
      #   owner   => $user,
      #   group   => $group,
      #   mode    => '0770',
      #   require => File["${title}@${user_home}/.config/pcmanfm-qt"],
      # }

      # file { "${title}@${user_home}/.config/pcmanfm-qt/lxqt/desktop-items-0.conf":
      #   ensure  => file,
      #   path    => "${user_home}/.config/pcmanfm-qt/lxqt/desktop-items-0.conf",
      #   replace => false,
      #   owner   => $user,
      #   group   => $group,
      #   mode    => '0770',
      #   require => File["${title}@${user_home}/.config/pcmanfm-qt/lxqt"],
      # }

      ini_setting { "${title}@shortcut-position":
        ensure  => present,
        path    => "${user_home}/.config/pcmanfm-qt/lxqt/desktop-items-0.conf",
        section => $shortcut_filename,
        setting => 'pos',
        value   => "@Point(${position['x']}, ${position['y']})",
        require => [
          # File["${title}@${user_home}/.config/pcmanfm-qt/lxqt/desktop-items-0.conf"],
          File["${title}@shortcut"],
        ],
      }
    }
  }
}
