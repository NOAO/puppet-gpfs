class gpfs::service {
  service { 'gpfs':
# /etc/init.d/gpfs status|restart are noops
#    ensure     => running,
#    hasstatus  => false,
#    hasrestart => false,
    enable  => true,
    require => Class['gpfs::install'],
  }
}
