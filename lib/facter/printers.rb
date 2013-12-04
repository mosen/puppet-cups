# Create a fact which generates a list of comma separated printers
Facter.add(:printers) do
  confine :kernel => %w{Linux FreeBSD OpenBSD SunOS HP-UX Darwin GNU/kFreeBSD}
  setcode do
    ENV['LANG'] = 'C'
    if printers_list = Facter::Util::Resolution.exec("/usr/bin/lpstat -p 2>/dev/null")
      printers = printers_list.split("\n").map do |line|
        cap = line.match(/^printer (.*?) /)
        if cap.nil?
          nil
        else
          cap.captures[0]
        end
      end
      printers.compact.join(',')
    end
  end
end
