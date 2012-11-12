class puppet::proxy::base inherits puppet::master::standalone::plain {

  # TODO: use parameters/hiera
  $ca_root = '/srv/puppetca'
  $default_backend = 'puppetmaster-legacy'
  $certname = $puppet_server

  include nginx
  include concat::setup

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

  Puppet::Config['master/ca'] {
    value => true,
  }

  Puppet::Config['master/certname'] {
    value => $certname,
  }

  Puppet::Config['master/ssldir'] {
    value => $ssldir,
  }

  # Workers
  concat {'/etc/nginx/puppet-sslproxy/workers.conf':
    notify => Service['nginx'],
  }

  # Routing
  concat {'/etc/nginx/puppet-sslproxy/routing.conf':
    notify  => Service['nginx'],
  }

  # Default route
  $location = '.*'
  $backend_name = $default_backend
  concat::fragment {'puppet_proxy_route_default':
    ensure  => present,
    order   => '99',
    target  => '/etc/nginx/puppet-sslproxy/routing.conf',
    content => template('puppet/proxy_nginx_route.erb'),
  }

}
