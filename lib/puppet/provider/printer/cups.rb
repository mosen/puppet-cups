require 'shellwords'

Puppet::Type.type(:printer).provide :cups, :parent => Puppet::Provider do
  desc "This provider manages installed printers using CUPS command line tools

  The provider is developed under Mac OS X but is intended to work with any unix/linux distribution
  supported by CUPS.

  The device uri isn't validated as the provider doesn't determine which uri's are available.
  You will need to check that your uri is valid. You can get a list of valid uri's by executing:

  $ lpinfo -v

  See the lpinfo(8) man page for more detail.

  If you use the model parameter to select your printer model, it should be one of the valid models listed by lpinfo
  like so:

  $ lpinfo -m

  The model cannot be determined after the printer has been created, so it usually can't be changed after you create
  a printer.
  "

  commands :lpadmin => "/usr/sbin/lpadmin"
  commands :lpoptions => "/usr/bin/lpoptions"
  commands :lpstat => "/usr/bin/lpstat"

  commands :cupsenable => "/usr/sbin/cupsenable"
  commands :cupsdisable => "/usr/sbin/cupsdisable"
  commands :cupsaccept => "/usr/sbin/cupsaccept"
  commands :cupsreject => "/usr/sbin/cupsreject"

  mk_resource_methods

  # A hash of type parameters to command line short switches.
  Cups_Options = {
      # :class       => '-c%s', # Unsupported, for now
      :model       => '-m%s', # Not idempotent
      :uri         => '-v%s',
      :description => '-D%s',
      :location    => '-L%s',
      :ppd         => '-P%s'  # Also not idempotent
  }

  # The instances method collects information through a number of different command line utilities because no single
  # utility displays all of the information about a printer's configuration.
  def self.instances
    prefetched_uris = printer_uris
    provider_instances = []

    printers_long.each do |name, printer|

      # Temporarily disabling options in instances
      #printer[:options] = self.printer_options(name)
      printer[:provider] = :cups
      printer[:uri] = prefetched_uris[printer[:name]] if prefetched_uris.key?(printer[:name])

      # derived from options
      printer[:shared] = printer[:options]['printer-is-shared']

      provider_instances << new(printer)
    end

    provider_instances
  end

  def self.prefetch(resources)
    prefetched_uris = printer_uris
    prefetched_printers = printers_long

    resources.each do |name, resource|

      if prefetched_printers.has_key? name
        printer = prefetched_printers[name]

        printer[:ensure] = :present
        printer[:options] = self.printer_options(name, resource)
        printer[:provider] = :cups
        printer[:uri] = prefetched_uris[printer[:name]] if prefetched_uris.key?(printer[:name])

        # derived from options
        printer[:shared] = printer[:options]['printer-is-shared']

        resource.provider = new(printer)
      else
        resource.provider = new(:ensure => :absent)
      end
    end
  end

  # TODO: Needs a much more efficient way of parsing `lpstat -l -p` output.
  # TODO: i18n
  def self.printers_long
    printers = {}

    begin
      printer = { :accept => :true } # Current printer entry being parsed

      lpstat('-l', '-p').split("\n").each { |line|
        case line
          when /^printer/

            if printer.key? :name # Push the last result
              printers[printer[:name]] = printer
              printer = { :accept => :true } # Current printer entry being parsed
            end

            header = line.match(/printer (.*) (disabled|is idle)/).captures # TODO: i18n

            printer[:name] = header[0]
            printer[:enabled] = (header[1] != 'disabled') ? :true : :false

          when /^\tDescription/
            printer[:description] = line.match(/\tDescription: (.*)/).captures[0]
          when /^\tLocation/
            printer[:location] = line.match(/\tLocation: (.*)/).captures[0]
          when /^\tInterface/
            printer[:ppd] = line.match(/\tInterface: (.*)/).captures[0]
          when /^\tRejecting Jobs/
            printer[:accept] = :false
        end
      }

      printers[printer[:name]] = printer

      printers
    rescue
      debug 'lpstat did not return any results'
      printers
    end
  end


  # Retrieve options explicitly specified by the type definition.
  def self.printer_options(destination, resource)
    options = {}

    return options unless resource[:options].kind_of? Hash

    # I'm using shellsplit here from the ruby std lib to avoid having to write a quoted string parser.
    Shellwords.shellwords(lpoptions('-d', destination)).each do |kv|
      values = kv.split('=')
      options[values[0]] = values[1] if resource[:options].key? values[0]
    end

    options
  end

  def self.printer_uris
    begin
      uris = {}

      lpstat('-v').split("\n").each { |line|
        caps = line.match(/device for (.*): (.*)/).captures # TODO: i18n
        uris[caps[0]] = caps[1]
      }

      uris
    rescue
      {}
    end
  end

  def create
    @property_hash[:ensure] = :present
    self.class.resource_type.validproperties.each do |property|
      if val = resource.should(property)
        @property_hash[property] = val
      end
    end
  end

  def destroy
    @property_hash[:ensure] = :absent
  end

  def exists?
    @property_hash[:ensure] != :absent
  end

  def flush

    case @property_hash[:ensure]
      when :absent
        lpadmin "-x", name
      when :present
        # Regardless of whether the printer is being added or modified, the `lpadmin -p` command is used.

        # BUG: flush should never be called if only the model or PPD parameters differ, because lpstat can't tell
        # what the actual value is.

        params = Array.new # lpadmin parameters
        options = Array.new # lpoptions parameters

        # Handle most parameters via string substitution
        Cups_Options.keys.each do |k|
          params.unshift Cups_Options[k] % @resource[k] if @resource[k]
        end



        options.push '-o printer-is-shared=true' if @property_hash[:shared] === :true

        if @property_hash[:options].is_a? Hash
          @property_hash[:options].each_pair do |k, v|
            # EB: Workaround for some command line options having 2 forms, short switch via lpadmin or
            # long "option-name" via -o. We don't want to allow setting of these options via -o
            next if k == 'device-uri'
            next if k == 'printer-is-shared'
            next if k == 'printer-is-accepting-jobs'
            next if k == 'printer-state' # causes reject/enable to be ignored
            options.push "-o %s='%s'" % [k, v]
          end
        end

        begin
          # -E means different things when it comes before or after -p, see man page for explanation.
          if @property_hash[:enabled] === :true and @property_hash[:accept] === :true
            lpadmin "-p", name, "-E", params
          else
            lpadmin "-p", name, params
          end

          unless options.empty?
            lpoptions "-p", name, options
          end

          # -E option covers enable & accept both true, and allows us to skip the other utilities.
          #unless @property_hash[:enabled] === :true and @property_hash[:accept] === :true
            if @property_hash[:enabled] === :true
              cupsenable name
            else
              cupsdisable name
            end

            if @property_hash[:accept] === :true
              cupsaccept name
            else
              cupsreject name
            end
          #end
        rescue Exception => e
          # If an option turns out to be invalid, CUPS will normally add the printer anyway.
          # Normally, the printer should not even be created, so we delete it again to make things consistent.
          debug 'Failed to add printer successfully, deleting destination. error: ' + e.message
          lpadmin "-x", name

          raise e
        end

        # If not accepting & enabling, just perform the
    end

    @property_hash.clear
  end
end
