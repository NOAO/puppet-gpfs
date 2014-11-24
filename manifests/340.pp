# XXX class name is puppet 4.x incompatible; replace with gpfs::v340
class gpfs::340 {
  class {'gpfs::install' : gpfs_version => '3.4.0' }
}
