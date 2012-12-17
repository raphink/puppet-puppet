define puppet::proxy (
  $location,
  $order='10',
  $ensure='present',
  $comment=false
) {

  $backend_name = $name

  # Worker, realized from corresponding puppetmaster
  Concat::Fragment <<| title == "puppet_proxy_worker_${name}" |>>

  # Routing
  concat::fragment {"puppet_proxy_route_${name}":
    ensure  => $ensure,
    order   => $order,
    target  => '/etc/nginx/puppet-sslproxy/routing.conf',
    content => template('puppet/proxy_nginx_route.erb'),
  }

}
