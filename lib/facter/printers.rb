# Create a fact which generates a list of comma separated printers

Facter.add(:printers) do
  setcode do

    printers = %x{/usr/bin/lpstat -p}.split("\n").map do |line|
      line.match(/printer (.*) is/).captures[0]
    end

    printers.join(',')
  end
end