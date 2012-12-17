class puppet::master::standalone (
  $puppetmasters = '4',
  $backend_name = 'puppetmaster-default',
  $backend_fair = false,
  $backend_ip = $::ipaddress,
  $base_port = '18140',
  $daemon_options = '',
  $dbadapter = 'mysql',
  $dbhost = 'localhost',
  $dbname = 'puppet',
  $dbuser = 'puppet',
  $dbpassword = 'puppet',
  $dbconnections = '20',
) {

  class {'::puppet::master':
    dbadapter      => $dbadapter,
    dbhost         => $dbhost,
    dbname         => $dbname,
    dbuser         => $dbuser,
    dbpassword     => $dbpassword,
    dbconnections  => $dbconnections,
  }

  validate_re($::osfamily, ['Debian', 'kFreeBSD', 'RedHat'],
                  "Unsupported OS family ${::osfamily}")

  validate_re($puppetmasters, '\d+', 'puppetmasters must be an integer')
  validate_re($base_port, '\d+', 'base_port must be an integer')
  validate_bool($backend_fair)

  case $::lsbdistcodename {
    'wheezy': {
      $server_type = 'thin'
      $hasstatus = false
      include ::puppet::master::standalone::thin
    }

    default: {
      $server_type = 'mongrel'
      $hasstatus = true
      include ::puppet::master::standalone::mongrel
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
        "set PUPPETMASTERS ${puppetmasters}",
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

  $_changes_opts = $daemon_options ? {
    ''      => $changes_opts,
    default => $daemon_options,
  }

  augeas {'configure puppetmaster options':
    context => $context,
    changes => $_changes_opts,
    notify  => Service['puppetmaster'],
  }

  # Exported for proxy
  @@concat::fragment { "puppet_proxy_worker_${backend_name}":
    ensure  => present,
    target  => '/etc/nginx/puppet-sslproxy/workers.conf',
    content => template('puppet/proxy_nginx_worker.erb'),
  }

}
