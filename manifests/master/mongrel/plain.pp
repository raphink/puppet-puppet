class puppet::master::mongrel::plain {

  include puppet::master::mongrel::standalone

  case $::osfamily {
    /Debian|kFreeBSD/: {
      $context  = '/files/etc/default/puppetmaster' 
      $opts_key = 'DAEMON_OPTS'
    }

    'RedHat': {
      $context  = '/files/etc/sysconfig/puppetmaster' 
      $opts_key = 'PUPPETMASTER_EXTRA_OPTS'
    }

    default: { fail("Unknown OS family ${::osfamily}") }
  }

  augeas { "configure puppetmaster standalone mongrel":
    context => $context,
    changes => "set ${opts_key} '\"--confdir=/srv/puppetmaster/stable --ssl_client_header=HTTP_X_CLIENT_DN --ssl_client_verify_header=HTTP_X_CLIENT_VERIFY --bindaddress=0.0.0.0\"'",
    notify  => Service["puppetmaster"],
    require => Augeas['configure puppetmaster startup variables'],
  }

}
