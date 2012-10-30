class puppet::master::standalone::thin {

  file {'/etc/init.d/puppetmaster':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/puppet/puppetmaster_thin.init',
  }

  package {'thin':
    ensure => present,
    before => Service['puppetmaster'],
  }
}
