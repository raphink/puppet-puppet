class puppet::proxy::base (
  $ca_root = '/srv/puppetca',
  $certname = $::fqdn,
  $backend_name = 'puppetmaster-ca',
  $backend_ip = '127.0.0.1',
  $puppetmasters = '1',
  $worker = true,
) {

  validate_re($::osfamily, ['Debian', 'kFreeBSD', 'RedHat'],
                  "Unsupported OS family ${::osfamily}")

  validate_re($puppetmasters, '\d+', 'puppetmasters must be an integer')
  validate_string($backend_name, 'backend_name must be a string')

  include ::nginx
  include ::concat::setup

  package { 'mcollective-agent-puppetca': ensure => present }

  nginx::site { 'puppetmaster':
    conf_source => 'puppet/proxy_nginx.conf.erb',
  }

  file { '/etc/nginx/puppet-sslproxy/':
    ensure => directory,
  }

  file { '/etc/nginx/puppet-sslproxy/static.conf':
    ensure  => present,
    notify  => Service['nginx'],
    content => '
# serve static file for the [files] mountpoint
#location /production/file_content/files/ {
#    # it is advisable to have some access rules here
#    allow   172.16.0.0/16;
#    deny    all;

#    alias /etc/puppet/files/;
#}

## serve modules files sections
#location ~ /production/file_content/[^/]+/files/ {
#    # it is advisable to have some access rules here
#    allow   172.16.0.0/16;
#    deny    all;

#    root /etc/puppet/modules;

#    # rewrite /production/file_content/module/files/file.txt
#    # to /module/file.text
#    rewrite ^/production/file_content/([^/]+)/files/(.+)$  $1/$2 break;
#}
',
  }

  file {$ca_root:
    ensure => directory,
    owner  => 'puppet',
    group  => 'root',
  }

# TODO:
# - CA certs
# - protect traffic to puppetmaster backends (unicorn/passenger + https ?)
# - prevent direct access to static files
# - reduce mongrels to 1

  $ssldir = $ca_root ? {
    default => $ca_root,
    ''      => '/var/lib/puppet/ssl',
  }

  puppet::config {
    'puppetca/ssldir':   value => $ssldir;
    'puppetca/certname': value => $certname;
  }

  if $worker {
    class {'::puppet::master::standalone::plain':
      puppetmasters => $puppetmasters,
      backend_name  => $backend_name,
      backend_ip    => $backend_ip,
      ca            => true,
      certname      => $certname,
      ssldir        => $ssldir,
    }
  }

  # Workers
  concat {'/etc/nginx/puppet-sslproxy/workers.conf':
    notify => Service['nginx'],
  }

  # Routing
  concat {'/etc/nginx/puppet-sslproxy/routing.conf':
    notify  => Service['nginx'],
  }
}
