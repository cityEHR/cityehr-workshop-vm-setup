type Position = Struct[{
    provider => Enum['lxqt'],
    x => Variant[Integer, String],
    y => Variant[Integer, String],
}]

class xdesktop {
  $home = $os['name'] ? {
    /(FreeBSD|OpenBSD|NetBSD)/ => '/usr/home',
    'MacOS'                    => '/Users',
    default                    => '/home',
  }
}
