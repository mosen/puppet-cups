## puppet-cups module

## User Guide

### Overview

This type provides the ability to manage cups printers and options.

Limitations:
+ It currently does not support classes.
+ It currently does not set default printers.
+ It does not set vendor ppd options (where an external process is responsible for modifying the ppd).

### Installation

This module should be cloned or otherwise copied into your modulepath.

If you are not sure where your module path is try this command:

    puppet --configprint modulepath

This module provides new types in the form of plugins, so your Puppet configuration
(ie. puppet.conf) must include a pluginsync directive like this:

    [agent]
    pluginsync = true

Without pluginsync, any manifest with a `printer` resource in it will throw an error.

### Examples

The most basic printer install possible:

    printer { "Basic_Printer":
        ensure      => present,
        uri         => "lpd://hostname/printer_a",
        description => "This is the printer description",
        ppd         => "/Library/Printers/PPDs/Printer.ppd", # PPD file will be autorequired
    }

Removing the printer "Basic_Printer" from the previous example:

    printer { "Basic_Printer":
        ensure      => absent,
    }

More advanced install using most of the available properties:

    printer { "Extended_Printer":
        ensure      => present,
        uri         => "lpd://localhost/printer_a",
        description => "This is the printer description",
        location    => "Main office",
        ppd         => "/Library/Printers/PPDs/Printer.ppd", # Full path to vendor PPD
        # OR
        model       => "", # A valid model, you can list these with lpinfo -m
        enabled     => true, # Enabled by default
        shared      => false, # Disabled by default
        options     => { media => 'A4' }, # Hash of options ( name => value )
    }

You can also set a number of default options which will apply to all printers by using the printer_defaults resource.
For instance if you wanted to default the media option to 'A4' for all printers:

    printer_defaults { "media":
        ensure => present,
        value  => "A4",
    }

You can also set printer_defaults to ensure => absent, if you want the option to be unset.

### Facts

The module provides access to one additional facter fact "printers", which provides a comma separated list of installed
printers.

See the __lpadmin(8)__  manual page for more information on valid device-uri's.
You can execute __lpoptions -l__ to list the valid options for the current printer.

For more information refer to the CUPS administrators manual.

### Bugs

Please submit any issues through Github issues as I don't have a dedicated project page for this module.

## Developer Guide

### Vendor PPD Options

The provider does not currently generate PPD files based upon the vendor supplied printer definition. This means that
if the vendor has supplied a PPD with Apple extensions i.e You see a UI which allows you to pick printer features, then
you need to generate your own ppd first for distribution.

I would recommend doing a manual installation of the printer with the customizations from the ui picker, and then using
the resulting PPD as the printer description. On OS X you can retrieve the ppd from /private/etc/cups/ppd after you have
customized the printer features.

### Contributing

You can issue a pull request and send me a message if you like, and I will consider taking the patch upstream :)

### Testing

The tests need a lot of improvement, but you can run them with RSpec in the typical way:

Make sure you have:

    rake

Install the necessary gems:

    gem install rspec

And run the tests from the root of the source code:

    rake test