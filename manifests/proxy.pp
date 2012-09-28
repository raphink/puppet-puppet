define puppet::proxy (
  $backend,
  $location,
  $order='10',
  $ports=['18140','18141','18142','18143'],
  $fair=true,
  $ensure='present',
  $comment=false
) {

  $backend_name = $name

  # Worker
  concat::fragment { "puppet_proxy_worker_${name}":
    ensure  => $ensure,
    order   => $order,
    target  => '/etc/nginx/puppet-sslproxy/workers.conf',
    content => template('puppet/proxy_nginx_worker.erb'),
  }

  # Routing
  concat::fragment {"puppet_proxy_route_${name}":
    ensure  => $ensure,
    order   => $order,
    target  => '/etc/nginx/puppet-sslproxy/routing.conf',
    content => template('puppet/proxy_nginx_route.erb'),
  }

}
