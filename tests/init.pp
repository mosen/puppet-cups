# Demonstrate usage of the printer resource type, and the cups provider
node default {

    # Test bug where single quote caused location string to fail
    printer { "Printer_A":
        ensure       => present,
        uri          => "http://localhost",
        description  => "This is the printer description",
        location     => "John's office",
        shared       => false,
        error_policy => abort_job,
    }

}