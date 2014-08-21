Puppet::Type.newtype(:printer) do
  @doc = "Manage installed printers and printer queues on a puppet node."

  ensurable

  newparam(:name, :isnamevar => true) do
    desc "The name of the printer, any character except SPACE, TAB, / or #, Not case sensitive"

    validate do |value|
      raise ArgumentError, "%s is not a valid printer name" % value if value =~ /[\s\t\/#]/
    end
  end

  newproperty(:uri) do
    desc "Sets the device-uri attribute of the printer destination."
  end

  newproperty(:description) do
    desc "Provides a textual description of the destination."
  end

  newproperty(:location) do
    desc "Provides a textual location of the destination."
  end

  # NOTE: model and ppd are parameters because they cannot be idempotent. CUPS will copy and rename the ppd
  # upon printer creation (on mac os x at least), therefore: you can only change the model/ppd when the printer is
  # created.
  newparam(:model) do
    desc "Sets a standard System V interface script or PPD file for the printer from the model directory.

    Use the -m option with the lpinfo(8) command to get a list of supported models.
    "
  end

  newparam(:ppd) do
    desc "Specifies a PostScript Printer Description file to use with the printer."
  end

  newparam(:interface) do
    desc "Specifies a System V interface file to use with the printer."
  end

  newproperty(:enabled) do
    desc "Enables the destination and accepts jobs"

    newvalues(:true, :false)
    defaultto :true
  end

  newproperty(:accept) do
    desc "Specifies whether the destination will accept jobs, or reject them."

    newvalues(:true, :false)
    defaultto :true
  end

  newparam(:shared) do
    desc "Sets the destination to shared/published or unshared/unpublished."

    newvalues(:true, :false)
    defaultto :false
  end

  # Error policy is a parameter because it is not displayed in the output of
  # lpoptions -p or lpoptions -p -l, so it cannot be idempotent.
  newparam(:error_policy) do
    desc "Set the error policy for this destination, one of: abort_job, retry_job, retry_current_job, or stop_printer"

    newvalues(:abort_job, :retry_job, :retry_current_job, :stop_printer)
  end

  newproperty(:options) do
    desc "Sets a list of options for the printer using lpoptions. These options may only apply to lp/lpr jobs submitted
    locally"

    validate do |value|
      raise ArgumentError, "invalid value supplied for printer options" unless value.is_a? Hash
    end
  end

  newparam(:ppd_options) do
    desc "Set additional PPD options for this printer. These are only set upon creation.

    Use lpoptions -p destination -l to get a list of valid vendor PPD options for that queue."

    validate do |value|
      raise ArgumentError, "invalid value supplied for printer PPD options" unless value.is_a? Hash
    end
  end

  # Standard PPD Options - Only set on creation

  newparam(:input_tray) do
    desc "Set the input slot/input tray (Value depends on PPD)"
  end

  newparam(:duplex) do
    desc "Set duplex mode (Value depends on PPD)"
  end
  #
  newparam(:page_size) do
    desc "Set the page size (Value depends on PPD)"
  end
  #
  newparam(:color_model) do
    desc "Set the color model (CMY, CMYK, RGB, Gray)"
  end

  # Allow a printer resource without explicitly specifying a file resource for the PPD.
  autorequire(:file) do
     self[:ppd] if self[:ppd]
  end
end
