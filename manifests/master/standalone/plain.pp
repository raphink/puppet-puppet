class puppet::master::standalone::plain (
  $puppetmasters = '4',
  $backend_name = 'puppetmaster-legacy',
  $backend_fair = false,
  $backend_ip = $::ipaddress,
  $base_port = '18140',
  $dbadapter = 'mysql',
  $dbhost = 'localhost',
  $dbname = 'puppet',
  $dbuser = 'puppet',
  $dbpassword = 'puppet',
  $dbconnections = '20',
  $ca = false,
  $certname = '',
  $ssldir = '',
) {

  validate_re($::osfamily, ['Debian', 'kFreeBSD', 'RedHat'],
                  "Unsupported OS family ${::osfamily}")

  validate_re($puppetmasters, '\d+', 'puppetmasters must be an integer')
  validate_re($base_port, '\d+', 'base_port must be an integer')
  validate_bool($backend_fair)
  validate_string($backend_name, 'backend_name must be a string')

  $daemon_opts = $::osfamily ? {
    /Debian|kFreeBSD/ => 'set DAEMON_OPTS \'"--bindaddress=0.0.0.0"\'',
    'RedHat'          => 'set PUPPETMASTER_EXTRA_OPTS \'"--bindaddress=0.0.0.0"\'',
    default           => '',
  }

  $certname_ensure = $certname ? {
    ''      => absent,
    default => present,
  }

  $ssldir_ensure = $ssldir ? {
    ''      => absent,
    default => present,
  }

  puppet::config {
    'master/ssl_client_header':        value => 'HTTP_X_CLIENT_DN';
    'master/ssl_client_verify_header': value => 'HTTP_X_CLIENT_VERIFY';
    'master/ssldir':
      ensure => $ssldir_ensure,
      value  => $ssldir;
    'master/certname':
      ensure => $certname_ensure,
      value  => $certname;
    'master/ca':
      value  => $ca;
  }

  class {'::puppet::master::standalone':
    puppetmasters  => $puppetmasters,
    backend_name   => $backend_name,
    backend_fair   => $backend_fair,
    backend_ip     => $backend_ip,
    base_port      => $base_port,
    daemon_options => $daemon_opts,
    dbadapter      => $dbadapter,
    dbhost         => $dbhost,
    dbname         => $dbname,
    dbuser         => $dbuser,
    dbpassword     => $dbpassword,
    dbconnections  => $dbconnections,
  }

}
