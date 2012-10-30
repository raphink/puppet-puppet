class puppet::master::standalone {
  include puppet::master

  $_puppetmasters = $puppetmasters ? {
    ''      => '4',
    default => $puppetmasters,
  }

  $backend_name = $puppetmaster_backend_name ? {
    ''      => 'puppetmaster-legacy',
    default => $puppetmaster_backend_name,
  }

  $backend_fair = $puppetmaster_backend_fair ? {
    ''      => false,
    default => $puppetmaster_backend_fair,
  }

  $backend_ip = $puppetmaster_backend_ip ? {
    ''      => $::ipaddress,
    default => $puppetmaster_backend_ip,
  }

  $base_port = 18140

  case $::lsbdistcodename {
    'wheezy': {
      $server_type = 'thin'
      $hasstatus = false
      include puppet::master::standalone::thin
    }

    default: {
      $server_type = 'mongrel'
      $hasstatus = true
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
    hasstatus => $hasstatus,
    enable    => true,
  }

  case $::osfamily {
    /Debian|kFreeBSD/: {
      $context = '/files/etc/default/puppetmaster'
      $changes_workers = [
        "set PORT ${base_port}",
        'set START yes',
        "set SERVERTYPE ${server_type}",
        "set PUPPETMASTERS ${_puppetmasters}",
      ]
      $changes_opts = 'rm DAEMON_OPTS'
    }

    'RedHat': {
      $context = '/files/etc/sysconfig/puppetmaster'
      $changes_workers = split(template('puppet/sysconfig_puppetmaster_redhat.erb'), '@')
      $changes_opts = "set PUPPETMASTER_EXTRA_OPTS \'\"--servertype=${server_type}"
    }

    default: { fail("Unknown OS family ${::osfamily}") }
  }

  augeas {'configure puppetmaster workers':
    context => $context,
    changes => $changes_workers,
    notify  => Service['puppetmaster'],
  }

  augeas {'configure puppetmaster options':
    context => $context,
    changes => $changes_opts,
    notify  => Service['puppetmaster'],
  }

  # Exported for proxy
  @@concat::fragment { "puppet_proxy_worker_${backend_name}":
    ensure  => present,
    target  => '/etc/nginx/puppet-sslproxy/workers.conf',
    content => template('puppet/proxy_nginx_worker.erb'),
  }

}
