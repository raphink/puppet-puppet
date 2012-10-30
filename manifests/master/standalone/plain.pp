class puppet::master::standalone::plain inherits puppet::master::standalone {

  $server_type = $puppet::master::standalone::server_type

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

  $changes = $::operatingsystem ? {
    /Debian|Ubuntu|kFreeBSD/ => [
      'set PORT 18140',
      'set START yes',
      "set SERVERTYPE ${server_type}",
      'set PUPPETMASTERS 4',
      "set DAEMON_OPTS '\"--bindaddress=0.0.0.0\"'",
    ],
    /RedHat|CentOS|Fedora/ => [
      'set PUPPETMASTER_PORTS/1 18140',
      'set PUPPETMASTER_PORTS/2 18141',
      'set PUPPETMASTER_PORTS/3 18142',
      'set PUPPETMASTER_PORTS/4 18143',
      "set PUPPETMASTER_EXTRA_OPTS '\"--bindaddress=0.0.0.0\"'",
    ],
  }

  puppet::config {
    'master/ssl_client_header':        value => 'HTTP_X_CLIENT_DN';
    'master/ssl_client_verify_header': value => 'HTTP_X_CLIENT_VERIFY';
    # TODO: put this in a class param/hiera
    # Note: mongrel will fail to start if this value is the same than on the
    # client !
    'master/ssldir':
      value   => $ca_root ? {
        default => $ca_root,
        '' => '/var/lib/puppet/ssl',
      };
  }

  Augeas['configure puppetmaster startup variables'] {
    changes => $changes,
  }

}
