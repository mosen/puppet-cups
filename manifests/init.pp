class cups (
  $package_ensure = $cups::params::package_ensure,
  $package_name = $cups::params::package_name,

  $devel_package_ensure = $cups::params::devel_package_ensure,
  $devel_package_name = $cups::params::devel_package_name,

  $service_ensure = $cups::params::service_ensure,
  $service_enabled = $cups::params::service_enabled,
  $service_name = $cups::params::service_name,

  $cups_lpd_enable = $cups::params::cups_lpd_enable,
  $package_cups_lpd = $cups::params::package_cups_lpd,
  $config_file = $cups::params::config_file,
) inherits cups::params {

  include '::cups::install'
  include '::cups::service'

  $printers_default = { ensure => present }
  create_resources('printer', hiera_hash(cups::printers, { }), $printers_default)

  if $cups::cups_lpd_enable {
      include '::cups::config'
  }
}
