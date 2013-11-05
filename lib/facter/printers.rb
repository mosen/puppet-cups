# Create a fact which generates a list of comma separated printers
Facter.add(:printers) do
  setcode do
    ENV['LANG'] = 'C'
    if printers_list = Facter::Util::Resolution.exec("/usr/bin/lpstat -p 2>/dev/null")
      printers = printers_list.split("\n").map do |line|
        line.match(/printer (.*) is/).captures[0]
      end
    printers.join(',')
    end
  end
end
