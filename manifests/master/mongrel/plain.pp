class puppet::master::mongrel::plain inherits puppet::master::mongrel::standalone {

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
      'set SERVERTYPE mongrel',
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
  }

  Augeas['configure puppetmaster startup variables'] {
    changes => $changes,
  }

}
