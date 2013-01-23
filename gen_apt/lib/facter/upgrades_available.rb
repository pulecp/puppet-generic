if File.exists?('/usr/bin/apt-get')
  # What does this do?
  # It simulates an apt-get upgrade, takes the output and finds all the lines starting with Inst and gets the package name from it.
  packages =  %x{/usr/bin/apt-get -s -o Debug::NoLocking=true upgrade}.scan(/^Inst ([^ ]*)/)
  Facter.add('upgrades_available') { setcode { packages.size } }
  Facter.add('upgrades_available_packages') { setcode { packages.join(',') } }
end

# And now for the upgraded packages
pkgs = ''
files = ['/var/log/dpkg.log','/var/log/dpkg.log.1']
files.each do |file|
  if File.exist?(file)
    File.open(file) do |io|
      io.each_line do |line|
        pkg = line.chomp.scan(/(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}) upgrade ([^ ]*) ([^ ]*) ([^ ]*)/).flatten
        if ! pkg.empty?
          pkgs += "#{pkg[1]}|#{pkg[0]}|#{pkg[2]}|#{pkg[3]};"
        end
      end
    end
  end
end

Facter.add(:upgraded_packages) { setcode { pkgs.chomp(';') } }
