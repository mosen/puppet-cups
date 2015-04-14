class cups (
  $package_ensure = $cups::params::package_ensure,
  $package_name = $cups::params::package_name,

  $devel_package_ensure = $cups::params::devel_package_ensure,
  $devel_package_name = $cups::params::devel_package_name,

  $service_ensure = $cups::params::service_ensure,
  $service_enabled = $cups::params::service_enabled,
  $service_name = $cups::params::service_name

) inherits cups::params {

  include '::cups::install'
  include '::cups::service'

  $printers_default = { ensure => present }
  create_resources('printer', hiera_hash(cups::printers), $printers_default)
}
