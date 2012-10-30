class puppet::master::standalone {
  include puppet::master

  case $::lsbdistcodename {
    'wheezy': {
      $server_type = 'thin'
      include puppet::master::standalone::thin
    }

    default: {
      $server_type = 'mongrel'
      include puppet::master::standalone::mongrel
    }
  }

  if ($::osfamily == 'Debian') {
    file {'/etc/alternatives/ruby':
      ensure => link,
      target => '/usr/bin/ruby1.8',
    }
  }

  service {'puppetmaster':
    ensure    => running,
    hasstatus => true,
    enable    => true,
  }

  case $::osfamily {
    /Debian|kFreeBSD/: {
      $context = '/files/etc/default/puppetmaster'
      $changes = [
        'set PORT 18140',
        'set START yes',
        "set SERVERTYPE ${server_type}",
        'set PUPPETMASTERS 4',
      ]
    }

    'RedHat': {
      $context = '/files/etc/sysconfig/puppetmaster'
      $changes = [
        "set PUPPETMASTER_EXTRA_OPTS '\"--servertype=${server_type}\"'",
        'set PUPPETMASTER_PORTS/1 18140',
        'set PUPPETMASTER_PORTS/2 18141',
        'set PUPPETMASTER_PORTS/3 18142',
        'set PUPPETMASTER_PORTS/4 18143',
      ]
    }

    default: { fail("Unknown OS family ${::osfamily}") }
  }

  augeas {'configure puppetmaster startup variables':
    context => $context,
    changes => $changes,
    notify  => Service['puppetmaster'],
  }
}
