#
class cups::params {
    $ensure         = present
    $enable         = true
    $source         = ''
    $package_name   = 'cups'
    $package_devel  = "${package_name}-devel"
}
