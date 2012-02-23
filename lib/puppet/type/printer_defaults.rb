Puppet::Type.newtype(:printer_defaults) do
  @doc = "Sets the global defaults for all printers on the system."

  ensurable

  newparam(:name, :isnamevar => true) do
    desc "The name of the option to set the default for."
  end

  newproperty(:value) do
    desc "The default value of the option being set."
  end
end