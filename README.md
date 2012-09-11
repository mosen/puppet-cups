## puppet-cups module

## User Guide

### Overview

This type provides the ability to manage cups printers and options.

Limitations:
+ It currently does not support classes.
+ It currently does not set default printers.
+ It does not set vendor ppd options (where an external process is responsible for modifying the ppd).

### Installation

You can install the latest release version from the module forge by executing this command:

    puppet module install mosen-cups

If you are feeling brave, or want to test the version in development you can clone the github repository into
your module path.

This module provides new types in the form of plugins, so pluginsync must be enabled for every agent in the
puppet configuration (usually /etc/puppet/puppet.conf) like this:

    [agent]
    pluginsync = true

Without pluginsync enabled, any manifest with a `printer` resource in it will throw an error
or possibly just do nothing.

### Examples

#### Basic

The most basic printer install possible:

    printer { "Basic_Printer":
        ensure      => present,
        uri         => "lpd://hostname/printer_a",
        description => "This is the printer description",
        ppd         => "/Library/Printers/PPDs/Printer.ppd", # PPD file will be autorequired
    }

- The uri identifies how you will connect to the printer. running `lpinfo -v` at the command line will give you some
valid uri prefixes.
- The description only appears in certain dialogs on linux and friends. On OSX the description is the actual name of
the printer.
- The ppd or model parameter specifies the "driver" to use with this printer. You should use `model` wherever available
because most driver software will install straight into the cups model directory. You can get a list of valid models by
running `lpinfo -m` at the command line.

Removing the printer "Basic_Printer" from the previous example:

    printer { "Basic_Printer":
        ensure      => absent,
    }

### Advanced

An example using almost every possible parameter:

    printer { "Extended_Printer":
        ensure      => present,
        uri         => "lpd://localhost/printer_a",
        description => "This is the printer description",
        location    => "Main office",
        ppd         => "/Library/Printers/PPDs/Printer.ppd", # Full path to vendor PPD
        # OR
        model       => "", # A valid model, you can list these with lpinfo -m, this is usually what you would call a
                           # list of installed drivers.
        enabled     => true, # Enabled by default
        shared      => false, # Disabled by default
        options     => { media => 'A4' }, # Hash of options ( name => value ), highly depends on the printer.
    }

- The easiest way to find out a list of valid options for any single printer is to install that printer locally, and
run `lpoptions -l` at the command line.

### Facts

The module provides access to one additional facter fact "printers", which provides a comma separated list of installed
printers.

For more information about printer options, models, and uri's, refer to the CUPS documentation.

### Bugs

Please submit any issues through Github issues as I don't have a dedicated project page for this module.

## Developer Guide

### OSX Specifics

#### Printer Presets

Each printer can have a set of options, normally presented in the print dialog, saved as a named preset.
Named presets are stored in property lists at the following location:

    ~/Library/Preferences/com.apple.print.custompresets._PRINTER_QUEUE_NAME_.plist

#### Default Printer

If you select "Last Used Printer", it will select the printer in:

    ~/Library/Preferences/org.cups.PrintingPrefs.plist

As the default printer.

If you want to set the default printer, you cannot use `lpoptions` or `lpadmin` to do it. The system preference pane
primarily reads and writes to:

    ~/.cups/lpoptions

To determine the current default printer queue. You can make this file part of your login script or manage it using
a commercial osx management solution.

#### Vendor PPD Options

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