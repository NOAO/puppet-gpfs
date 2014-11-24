# XXX class name is puppet 4.x incompatible; replace with gpfs::v350
class gpfs::350 {
  class {'gpfs::install' : gpfs_version => '3.5.0' }
}
