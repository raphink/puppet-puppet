class puppet::master::webrick inherits puppet::master {

  $context = $::operatingsystem ? {
    /Debian|Ubuntu|kFreeBSD/ => '/files/etc/default/puppetmaster',
    /RedHat|CentOS|Fedora/   => '/files/etc/sysconfig/puppetmaster',
  }

  $changes = $::operatingsystem ? {
    /Debian|Ubuntu|kFreeBSD/ => [
      'set PORT 8140',
      'set START yes',
      'set SERVERTYPE webrick',
      'set PUPPETMASTERS 1',
    ],
    /RedHat|CentOS|Fedora/ => [
      'set PUPPETMASTER_EXTRA_OPTS \'"--servertype=webrick"\'',
      'rm  PUPPETMASTER_PORTS',
    ],
  }

  augeas {'configure puppetmaster startup variables':
    context => $context,
    changes => $changes,
    notify  => Service['puppetmaster'],
  }

  service {'puppetmaster':
    ensure  => running,
    enable  => true,
    require => Package['puppetmaster'],
  }

}
