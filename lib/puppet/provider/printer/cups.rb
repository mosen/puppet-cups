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

  commands :lpadmin => '/usr/sbin/lpadmin'
  commands :lpoptions => '/usr/bin/lpoptions'
  commands :lpstat => '/usr/bin/lpstat'

  #
  # candidate locations for the enable command
  # Solaris 11 & Illumos/OpenIndiana have /usr/bin/{enable,disable}
  #
  [ "/usr/sbin/cupsenable",
    "/usr/bin/cupsenable",
    "/usr/sbin/enable",
    "/usr/bin/enable"].each do |cups_command|
    if File.exists?(cups_command)
      commands :cupsenable => cups_command
      break
    end
  end

  [ "/usr/sbin/cupsdisable",
    "/usr/bin/cupsdisable",
    "/usr/sbin/disable",
    "/usr/bin/disable"].each do |cups_command|
    if File.exists?(cups_command)
      commands :cupsdisable => cups_command
      break
    end
  end

  #
  # Candidate locations for the accept and reject commands
  # Older Fedora and RHEL/CentOS 6.x and earlier have /usr/sbin/{accept,reject}
  # Solaris 11 & Illumos/OpenIndiana have the same.
  #
  [ "/usr/sbin/cupsaccept",
    "/usr/bin/cupsaccept",
    "/usr/sbin/accept",
    "/usr/bin/accept"].each do |cups_command|
    if File.exists?(cups_command)
      commands :cupsaccept => cups_command
      break
    end
  end

  [ "/usr/sbin/cupsreject",
    "/usr/bin/cupsreject",
    "/usr/sbin/reject",
    "/usr/bin/reject"].each do |cups_command|
    if File.exists?(cups_command)
      commands :cupsreject => cups_command
      break
    end
  end

  mk_resource_methods

  # A hash of type parameters to command line short switches.
  CUPS_OPTIONS = {
      # :class       => '-c%s', # Unsupported, for now
      :model       => '-m%s', # Not idempotent
      :uri         => '-v%s',
      :description => '-D%s',
      :location    => '-L%s',
      :ppd         => '-P%s', # Also not idempotent
      :interface   => '-i%s'
  }

  # Options only alterable via lpadmin -p
  ADMIN_OPTIONS = %w{ device-uri printer-error-policy printer-is-shared job-sheets-default }

  # This array includes options that are either:
  #   - Not settable through any command line tool (including properties that report information)
  #   - Settable via a main flag to lpadmin AND via lpoptions (so we exclude the latter invocation)
  #   - Settable only upon creation of the queue/destination
  #
  # Notes:
  # printer-info: Should only be settable through description (-D) flag.
  # printer-location: Should only be settable through location (-L) flag.
  IMMUTABLE_OPTION_BLACKLIST = %w{ device-uri printer-is-accepting-jobs printer-state printer-error-policy marker-levels
  marker-names marker-colors marker-types marker-change-time printer-state-change-time printer-commands printer-info
  printer-location }

  # Options that can be set directly on the resource without the use of options or ppd_options
  OPTION_PROPERTIES = %w{ printer-is-shared }
  PPD_OPTION_PROPERTIES = %w{ PageSize InputSlot Duplex ColorModel }

  # The instances method collects information through a number of different command line utilities because no single
  # utility displays all of the information about a printer's configuration.
  def self.instances
    prefetched_uris = printer_uris
    provider_instances = []

    printers_long.each do |name, printer|

      printer[:ensure] = :present
      printer[:provider] = :cups
      printer[:uri] = prefetched_uris[printer[:name]] if prefetched_uris.key?(printer[:name])

      # Fetch CUPS options set on this destination
      # This typically includes the options stated in `lpadmin` man page for the -o flag.
      options = self.printer_options(name, nil)
      
      # Grab options that are set via properties or parameters
      printer[:shared] = options['printer-is-shared'] if options.has_key? 'printer-is-shared'
      
      # and reject them from the list of settable options
      options.reject! { |k, _| OPTION_PROPERTIES.include? k }
      printer[:options] = options

      # Fetch PPD options (model dependent)
      # Defined by the driver, but there are some standard properties.
      vendor_options = self.ppd_options name

      printer[:page_size] = vendor_options['PageSize'] if vendor_options.has_key? 'PageSize'
      printer[:input_tray] = vendor_options['InputSlot'] if vendor_options.has_key? 'InputSlot'
      printer[:duplex] = vendor_options['Duplex'] if vendor_options.has_key? 'Duplex'
      printer[:color_model] = vendor_options['ColorModel'] if vendor_options.has_key? 'ColorModel'

      vendor_options.reject! { |k, _| PPD_OPTION_PROPERTIES.include? k }
      printer[:ppd_options] = vendor_options

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
        printer[:provider] = :cups
        printer[:uri] = prefetched_uris[printer[:name]] if prefetched_uris.key?(printer[:name])

        # Fetch CUPS options set on this destination
        # This includes options stated in `lpadmin` man page as well as non-default PPD options
        options = self.printer_options(name, resource)

        # Grab options that are set via properties or parameters
        printer[:shared] = options['printer-is-shared'] if options.has_key? 'printer-is-shared'
      
        # and reject them from the list of settable options
        options.reject! { |k, _| OPTION_PROPERTIES.include? k }
        printer[:options] = options

        # Fetch PPD options with defaults and current values indicated by asterisk
        vendor_options = self.ppd_options name

        printer[:page_size] = vendor_options['PageSize'] if vendor_options.has_key? 'PageSize'
        printer[:input_tray] = vendor_options['InputSlot'] if vendor_options.has_key? 'InputSlot'
        printer[:duplex] = vendor_options['Duplex'] if vendor_options.has_key? 'Duplex'
        printer[:color_model] = vendor_options['ColorModel'] if vendor_options.has_key? 'ColorModel'

        vendor_options.delete_if { |k, _| PPD_OPTION_PROPERTIES.include? k }

        unless resource[:ppd_options].nil?
          resource_ppd_options = resource[:ppd_options]
          current_ppd_options = vendor_options.reject { |k, _| !resource_ppd_options.has_key? k }
          printer[:ppd_options] = current_ppd_options
        end

        resource.provider = new(printer)
      else
        resource.provider = new(:ensure => :absent)
      end
    end
  end


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

            header = line.match(/printer (.*) (disabled|is idle|now printing)/).captures

            printer[:name] = header[0]
            printer[:enabled] = (header[1] != 'disabled') ? :true : :false

          when /^\tDescription/
            printer[:description] = line.match(/\tDescription: (.*)/).captures[0]
          when /^\tLocation/
            printer[:location] = line.match(/\tLocation: (.*)/).captures[0]
          when /^\tInterface.*\/interface\/.*/
            printer[:interface] = line.match(/\tInterface: (.*)/).captures[0]
          when /^\tInterface.*\/ppd\/.*/
            printer[:ppd] = line.match(/\tInterface: (.*)/).captures[0]
          when /^\tRejecting Jobs/
            printer[:accept] = :false
          else
            # debug 'Unrecognised output from lpstat: %s' % line
        end
      }

      printers[printer[:name]] = printer

      printers
    rescue
      debug 'execution of lpstat failed, returning empty hash'
      printers
    end
  end

  # queue options are space separated, and come in pairs separated by equals(=)
  # NOTE: single quotation marks in option values are not escaped. So this makes things very difficult to parse.
  def self.printer_options(destination, resource)
    options = {}

    # I'm using shellsplit here from the ruby std lib to avoid having to write a quoted string parser.
    Shellwords.shellwords(lpoptions('-p', destination)).each do |kv|
      values = kv.split('=')

      # Reiterate: These would be impossible to change using lpadmin
      next if IMMUTABLE_OPTION_BLACKLIST.include? values[0]

      # Only fetch options that were declared, if there exists a resource at all (not when executing self.instances)
      next unless resource.nil? or resource[:options].nil? or resource[:options].include? values[0]

      options[values[0]] = values[1]
    end

    options
  end

  # vendor PPD options are formatted differently:
  # ShortName/Long Name: *Selected NotSelectedValue
  # If something other than the default is selected, it turns up in lpoptions -p
  def self.ppd_options(destination)
    begin
      debug "Fetching queue PPD options for #{destination}"
      output = lpoptions '-p', destination, '-l'

      output.each_line.inject({}) do |hash, line|
        kv = line.split(':')
        key = kv[0].split('/', 2)[0]

        selected_value = /\*(\w+)/.match(kv[1]).captures[0]

        hash[key] = selected_value
        hash
      end
    rescue
      debug 'Failed to fetch PPD options, this may be normal behaviour depending on printer setup.'
      {}
    end
  end

  def self.printer_uris
    begin
      debug 'Fetching all queue device URIs'
      output = lpstat '-v'
      uris = {}

      output.split("\n").inject({}) do |hash, line|
        caps = line.match(/device for (.*): (.*)/).captures
        hash[caps[0]] = caps[1].gsub(/^\//, 'file:/')
        hash
      end
    rescue
      debug 'Failed to fetch URIs, see --debug command output above'
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
        # Some parameters to lpadmin only apply on creation (model, interface, device uri, ppd). Others can be modified
        # after the destination has been created.

        params = Array.new
        options = Array.new
        vendor_options = Array.new

        # Short form lpadmin parameters
        CUPS_OPTIONS.keys.each do |k|
          params.unshift CUPS_OPTIONS[k] % @resource[k] if @resource[k]
        end

        unless @resource[:shared].nil?
          params.push "-o printer-is-shared=%s" % ((@resource[:shared] == :true) ? "true" : "false")
        end

        unless @resource[:error_policy].nil?
          params.push "-o printer-error-policy=%s" % {
              :abort_job => 'abort-job',
              :retry_job => 'retry-job',
              :retry_current_job => 'retry-current-job',
              :stop_printer => 'stop-printer' }[@resource[:error_policy]]
        end

        # Common PPD Options
        # `lpadmin` will happily set any of the values without complaining if the value is totally useless.
        # It is up to the user to verify that the PPD supports the named value.

        unless @resource[:page_size].nil?
          vendor_options.push "-o PageSize=%s" % @resource[:page_size]
        end

        unless @resource[:input_tray].nil?
          vendor_options.push "-o InputSlot=%s" % @resource[:input_tray]
        end

        unless @resource[:color_model].nil?
          vendor_options.push "-o ColorModel=%s" % @resource[:color_model]
        end

        unless @resource[:duplex].nil?
          vendor_options.push "-o Duplex=%s" % @resource[:duplex]
        end

        # Generic Options

        if @property_hash[:options].is_a? Hash
          @property_hash[:options].each_pair do |k, v|
            next if IMMUTABLE_OPTION_BLACKLIST.include? k
            options.push "-o %s='%s'" % [k, v]
          end
        end

        if @resource[:ppd_options].is_a? Hash
          @resource[:ppd_options].each_pair do |k, v|
            vendor_options.push "-o %s=%s" % [k, v]
          end
        end

        begin
          # -E means different things when it comes before or after -p, see man page for explanation.
          if @property_hash[:enabled] === :true and @property_hash[:accept] === :true
            lpadmin "-p", name, "-E", params
          else
            lpadmin "-p", name, params
          end

          # Some PPD Options cannot be set upon the creation of the destination for some reason: see PageSize.
          # So we call lpadmin again with vendor options.
          unless vendor_options.empty?
            lpadmin "-p", name, vendor_options
          end

          unless options.empty?
            lpadmin "-p", name, options
          end

          # Normally, the -E option would let us skip cupsenable/accept.
          # But the behaviour seems unpredictable when the queue already exists.
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
        rescue Exception => e
          # If an option turns out to be invalid, CUPS will normally add the printer anyway.
          # Normally, the printer should not even be created, so we delete it again to make things consistent.
          debug 'Failed to add printer successfully, deleting destination. error: ' + e.message
          lpadmin "-x", name

          raise e
        end
    end

    @property_hash.clear
  end
end
