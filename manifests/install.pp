class cups::install (
) {
    package { 'cups':
        name    => $cups::package_name,
        ensure  => $cups::package_ensure,
    }
}

