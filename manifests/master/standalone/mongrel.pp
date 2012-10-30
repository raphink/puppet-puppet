class puppet::master::standalone::mongrel {
  $mongrel = $::osfamily ? {
    'Debian' => 'mongrel',
    'RedHat' => 'rubygem-mongrel',
  }

  package {'mongrel':
    ensure => present,
    name   => $mongrel,
    before => Service['puppetmaster'],
  }

}
