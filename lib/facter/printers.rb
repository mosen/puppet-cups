# Get a list of printers which are installed and enabled for printing from CUPS

Facter.add(:printers) do
  setcode do

    %x{/usr/bin/lpstat -p}.split("\n").map do |line|
      line.match(/printer (.*) is/)[0]
    end
  end

end