#
class cups::install (
    $ensure = $cups::params::ensure,
    ) {
    #
    package { 'cups':
        name    => $cups::params::package_name,
        ensure  => $ensure,
    }
}

