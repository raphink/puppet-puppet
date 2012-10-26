class puppet::master::mongrel::standalone inherits puppet::master {

  # TODO: make mongrel count configurable

  # TODO:
  #   - Create puppet::master::standalone as a generic class
  #   - Create puppet::master::standalone::mongrel and puppet::master::standalone::thin

  case $::operatingsystem {
    /Debian|Ubuntu|kFreeBSD/: {
      case $::lsbdistcodename {
        'wheezy': {
          $mongrel = 'thin'

          file {'/etc/init.d/puppetmaster':
            ensure => present,
            owner  => 'root',
            group  => 'root',
            mode   => '0755',
            source => 'puppet:///modules/puppet/puppetmaster_thin.init',
          }
        }

        default: {
          $mongrel = 'mongrel'
        }
      }

      exec {'Use ruby1.8':
        command => 'update-alternatives --set ruby /usr/bin/ruby1.8 || true',
        unless  => 'test $(readlink /etc/alternatives/ruby) = /usr/bin/ruby1.8',
      }
    }

    /RedHat|CentOS|Fedora/: {
      $mongrel = 'rubygem-mongrel'
    }

    default: {
      fail "Unknown operating system ${::operatingsystem}"
    }
  }

  package {'mongrel':
    ensure => present,
    name   => $mongrel,
  }

  service {'puppetmaster':
    ensure    => running,
    hasstatus => true,
    enable    => true,
    require   => Package['mongrel'],
  }

  $context = $::operatingsystem ? {
    /Debian|Ubuntu|kFreeBSD/ => '/files/etc/default/puppetmaster',
    /RedHat|CentOS|Fedora/   => '/files/etc/sysconfig/puppetmaster',
  }

  $changes = $::operatingsystem ? {
    /Debian|Ubuntu|kFreeBSD/ => [
      'set PORT 18140',
      'set START yes',
      'set SERVERTYPE mongrel',
      'set PUPPETMASTERS 4',
    ],
    /RedHat|CentOS|Fedora/ => [
      'set PUPPETMASTER_EXTRA_OPTS \'"--servertype=mongrel"\'',
      'set PUPPETMASTER_PORTS/1 18140',
      'set PUPPETMASTER_PORTS/2 18141',
      'set PUPPETMASTER_PORTS/3 18142',
      'set PUPPETMASTER_PORTS/4 18143',
    ],
  }

  augeas {'configure puppetmaster startup variables':
    context => $context,
    changes => $changes,
    notify  => Service['puppetmaster'],
  }

}
