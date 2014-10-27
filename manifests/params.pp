class cups::params {
  $package_ensure = present
  $package_name = 'cups'

  $devel_package_ensure = undef
  $devel_package_name = "${package_name}-devel"

  $service_ensure = 'running'
  $service_enabled = true
  $service_name = 'cups'
}
