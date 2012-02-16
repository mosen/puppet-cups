class puppet-cups {
    notify { $printers: }
    #printer { "test":
    #    ensure => present,

    printer { "test":
        ensure => present,
#        uri => "/dev/null",
        location => "Non existent",
        description => "Test printer for puppet-cups module",
    }
}