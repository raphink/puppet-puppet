class puppet::master::standalone::plain inherits puppet::master::standalone {

  $server_type = $puppet::master::standalone::server_type
  $base_port = $puppet::master::standalone::base_port
  $_puppetmasters = $puppet::master::standalone::_puppetmasters

  case $::osfamily {
    /Debian|kFreeBSD/: {
      $context = '/files/etc/default/puppetmaster'
      $changes = [
        "set PORT ${base_port}",
        'set START yes',
        "set SERVERTYPE ${server_type}",
        "set PUPPETMASTERS ${_puppetmasters}",
        "set DAEMON_OPTS '\"--bindaddress=0.0.0.0\"'",
      ]
    }

    'RedHat': {
      $sysconfig_extra_opts = '--bindaddress=0.0.0.0'
      $context = '/files/etc/sysconfig/puppetmaster'
      $changes = template('puppet/sysconfig_puppetmaster_redhat.erb')
    }

    default: { fail("Unknown OS family ${::osfamily}") }
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
