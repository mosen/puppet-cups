# Create a fact which generates a list of comma separated printers
require 'open3'
Facter.add(:printers) do
  setcode do

    stdin, stdout, stderr = Open3.popen3('LANG=C /usr/bin/lpstat -p')
    printers = stdout.read
    if stderr.read.empty?
      printers = printers.split("\n").map do |line|
        line.match(/printer (.*) is/).captures[0]
      end
     printers.join(',')
    end
  end
end
