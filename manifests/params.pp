# Various default parmeters
class cups::params {
  $package_ensure       = present
  $package_name         = 'cups'

  $devel_package_ensure = undef
  $devel_package_name   = "${package_name}-devel"

  $service_ensure       = 'running'
  $service_enabled      = true
  $service_name         = 'cups'

  $cups_lpd_enable      = false
  $cups_lpd_ensure      = 'running'
  $package_cups_lpd     = 'cups-lpd'
  $config_file          = 'puppet:///modules/cups/cups-lpd'
}
