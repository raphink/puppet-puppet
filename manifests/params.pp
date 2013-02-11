# Simple puppet::params for theforeman's puppet-foreman_proxy module
class puppet::params {

  # Only use 'puppet cert' on versions where puppetca no longer exists
  if versioncmp($puppetversion, '3.0') < 0 {
    $puppetca_path = '/usr/sbin'
    $puppetca_bin  = 'puppetca'
    $puppetrun_cmd = '/usr/sbin/puppetrun'
  } else {
    $puppetca_path = '/usr/bin'
    $puppetca_bin = 'puppet cert'
    $puppetrun_cmd = '/usr/bin/puppet kick'
  }

  $puppetca_cmd = "${puppetca_path}/${puppetca_bin}"
}
