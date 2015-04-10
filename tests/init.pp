# Demonstrate usage of the printer resource type, and the cups provider
#node default {

    # Test bug where single quote caused location string to fail
    printer { "Printer_b":
        ensure       => present,
        uri          => "http://localhost",
        # description  => "This is the printer descriptionx",
        # location     => "John's office",
        # model        => 'drv:///sample.drv/generic.ppd',
        # shared       => false,
        # error_policy => 'abort_job',
        #  options      => {
        #    'auth-info-required' => 'negotiate',
        #  }
    }

    #  }
