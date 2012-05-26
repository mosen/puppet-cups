require 'shellwords'

Puppet::Type.type(:printer).provide :cups, :parent => Puppet::Provider do
  desc "This provider manages installed printers using CUPS command line tools

  The provider is developed under Mac OS X but is intended to work with any unix/linux distribution
  supported by CUPS.

  The device uri isn't validated as the provider doesn't determine which uri's are available.
  You will need to check that your uri is valid. You can get a list of valid uri's by executing:

  $ lpinfo -v

  See the lpinfo(8) man page for more detail.

  The PPD file location reported by cups might have been changed by cups (depending on the -m model option or -P ppd
  option, so it's difficult to identify whether our changes have taken effect. These parameters will only be set on
  creation (for the moment).
  "

  commands :lpadmin => "/usr/sbin/lpadmin"
  commands :lpoptions => "/usr/bin/lpoptions"
  #commands :lpinfo => "/usr/sbin/lpinfo"
  commands :lpstat => "/usr/bin/lpstat"

  #commands :cupsenable => "/usr/sbin/cupsenable"
  #commands :cupsdisable => "/usr/sbin/cupsdisable"

  #commands :cupsaccept => "/usr/sbin/cupsaccept"
  #commands :cupsreject => "/usr/sbin/cupsreject"

  has_feature :enableable

  mk_resource_methods

  # A hash of possible parameters to their command-line equivalents.
  Cups_Options = {
      :class       => '-c%s', # Not fully supported yet, but left here for the adventurous.
      :model       => '-m%s',
      :uri         => '-v%s', # lpadmin wont accept a quoted value for device-uri
      :description => '-D%s',
      :location    => '-L%s',
      :ppd         => '-P%s'
  }

  # Combine output of a number of commands to form a list of printer resources.
  def self.instances

    prefetched_uris = printer_uris
    prefetched_long = printers_long.collect { |printer|

      printer[:options] = self.printer_options(printer[:name])
      printer[:provider] = :cups
      printer[:uri] = prefetched_uris[printer[:name]] if prefetched_uris.key?(printer[:name])

      # derived from options
      printer[:shared] = printer[:options]['printer-is-shared']

      new(printer)
    }
    @property_hash = prefetched_long

    prefetched_long
  end

  def self.prefetch(resources)
    instances.each do |prov|
      if resource = resources[prov.name]
        resource.provider = prov
      end
    end
  end

  # Retrieve simple list of printer names
  def self.printers
    begin
      printers = lpstat('-p').split("\n").map { |line|
        line.match(/printer (.*) (is|disabled)/) {|m|
          m.captures[0]
        }
      }.compact

      printers
    rescue
      nil
    end
  end

  # Retrieve long listing of printers
  # The PPD path that CUPS uses may have been automatically reformatted or changed by CUPS. making it hard to keep
  # ppd location idempotent.
  #
  # TODO: figure out a more efficient way to parse the output. This will do for now.
  def self.printers_long
    printers = []
    printer = { :accept => true } # Current printer entry being parsed

    lpstat('-l', '-p').split("\n").each { |line|
      case line
        when /^printer/

          if printer.key? :name # Push the last result
            printers.push printer
            printer = { :accept => true } # Current printer entry being parsed
          end

          header = line.match(/printer (.*) (disabled|is idle)/).captures

          printer[:name] = header[0]
          printer[:enabled] = (header[1] != 'disabled')

        when /^\tDescription/
          printer[:description] = line.match(/\tDescription: (.*)/).captures[0]
        when /^\tLocation/
          printer[:location] = line.match(/\tLocation: (.*)/).captures[0]
        when /^\tInterface/
          printer[:ppd] = line.match(/\tInterface: (.*)/).captures[0]
        when /^\tRejecting Jobs$/
          printer[:accept] = false
      end
    }

    printers.push printer

    printers
  end


  # Retrieve options including whether the printer destination is shared.
  def self.printer_options(destination)
    options = {}

    # I'm using shellsplit here from the ruby std lib to avoid having to write a quoted string parser.
    Shellwords.shellwords(lpoptions('-d', destination)).each do |kv|
      values = kv.split('=')
      options[values[0]] = values[1]
    end

    options
  end

  # Retrieve Device-uri's
  def self.printer_uris
    uris = {}

    lpstat('-v').split("\n").each { |line|
      caps = line.match(/device for (.*): (.*)/).captures
      uris[caps[0]] = caps[1]
    }

    uris
  end

  def create
    options = Array.new

    # Handle most parameters via string substitution
    Cups_Options.keys.each do |k|
      options.unshift Cups_Options[k] % @resource[k] if @resource.parameters.key?(k)
    end

    options.push '-o printer-is-shared=true' if @resource[:shared]
    options.push '-E' if @resource[:enabled]

    if @resource[:options].is_a? Hash
      @resource[:options].each_pair do |k, v|
        options.push "-o %s='%s'" % k, v
      end
    end

    lpadmin "-p", @resource[:name], options
  end

  def destroy
    lpadmin "-x", @resource[:name]
  end

  # TODO: use prefetched resources instead of executing the utility again.
  def exists?
    if self.class.printers
      self.class.printers.select { |v| v.captures[0].downcase == @resource[:name].downcase }.length > 0
    else
      false
    end
  end

  def enabled
    @property_hash[:enabled].to_s
  end

  def accept
    @property_hash[:accept].to_s
  end

  def enable
    @property_hash[:enabled] = true
  end

  def disable
    @property_hash[:enabled] = false
  end

  def flush
    create
    @property_hash.clear
  end
end
