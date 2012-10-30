class puppet::master::standalone {
  include puppet::master

  $_puppetmasters = $puppetmasters ? {
    ''      => '4',
    default => $puppetmasters,
  }

  $base_port = 18140

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
        "set PORT ${base_port}",
        'set START yes',
        "set SERVERTYPE ${server_type}",
        "set PUPPETMASTERS ${_puppetmasters}",
      ]
    }

    'RedHat': {
      $sysconfig_extra_opts = "--servertype=${server_type}"
      $context = '/files/etc/sysconfig/puppetmaster'
      $changes = template('puppet/sysconfig_puppetmaster_redhat.erb')
    }

    default: { fail("Unknown OS family ${::osfamily}") }
  }

  augeas {'configure puppetmaster startup variables':
    context => $context,
    changes => $changes,
    notify  => Service['puppetmaster'],
  }
}
