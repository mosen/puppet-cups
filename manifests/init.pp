class cups (
    $ensure     = $cups::params::ensure,
    $enable     = $cups::params::enable,
    ) inherits cups::params {
    #
    class { 'cups::install': }
    class { 'cups::service': }
}
