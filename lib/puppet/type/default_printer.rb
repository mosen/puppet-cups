Puppet::Type.newtype(:default_printer) do
  @doc = "Manage the system wide default printer."

  ensurable

  newparam(:name, :isnamevar => true) do
    desc "The name of the default printer, any character except SPACE, TAB, / or #, Not case sensitive"

    validate do |value|
      raise ArgumentError, "%s is not a valid printer name" % value if value =~ /[\s\t\/#]/
    end
  end
end