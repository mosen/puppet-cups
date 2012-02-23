require 'shellwords'

Puppet::Type.type(:printer_defaults).provide :cups_options, :parent => Puppet::Provider do
  desc "This provider manages default printer options by executing lpoptions(1) as the root user.

  The root options are saved under /etc/cups/lpoptions.

  Note: On Mac OS X the default lpoptions do not correlate with the print dialog. The default printer and default media
  are selected by ~/Library/Preferences/com.apple.print.PrintingPrefs.plist (10.6) and submitted with the job options.

  Classes are parsed as normal printer destinations at the moment, and are interpreted as such.
  "

  commands :lpoptions => "/usr/bin/lpoptions"
  #commands :lpinfo => "/usr/sbin/lpinfo"

  mk_resource_methods

  # TODO: make this a mixin for the cups provider too.
  # Retrieve options including whether the printer destination is shared.
  def self.printer_options(destination = nil)
    options = {}

    if destination.nil?
      output = lpoptions
    else
      output = lpoptions('-d', destination)
    end

    # I'm using shellsplit here from the ruby std lib to avoid having to write a quoted string parser.
    output.shellsplit.each do |kv|
      values = kv.split('=')
      options[values[0]] = values[1]
    end

    options
  end

  # Combine output of a number of commands to form a list of printer resources.
  def self.instances
    prefetched_options = []

    self.printer_options().each do |key, value|
      prefetched_options << new({
        :name => key,
        :value => value,
        :provider => :cups_options
      })
    end

    prefetched_options
  end

  def self.prefetch(resources)
    instances.each do |prov|
      if resource = resources[prov.name]
        resource.provider = prov
      end
    end
  end

  def create
    lpoptions '-o', '%s=%s' % @resource[:name], @resource[:value]
  end

  def destroy
    lpoptions '-r', @resource[:name]
  end

  def exists?
    self.class.printer_options().key? @resource[:name]
  end
end