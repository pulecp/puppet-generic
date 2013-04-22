if File.exists?('/usr/bin/apt-get')
  # What does this do?
  # It simulates an apt-get upgrade, takes the output and finds all the lines starting with Inst and gets the package name from it.
  packages =  %x{/usr/bin/apt-get -s -o Debug::NoLocking=true upgrade}.scan(/^Inst ([^ ]*) \[([^\]]*)\] \(([^ ]*)/)
  fact = ''
  Facter.add('upgrades_available') { setcode { packages.size } }
  packages.each do |pkg|
    fact += "|#{pkg[0]}|#{pkg[1]}|#{pkg[2]};"
  end
  Facter.add('upgrades_available_packages') { setcode { fact.chomp(';') } }
end

# And now for the upgraded/installed/removed packages
pkgs_upgrade = ''
pkgs_remove = ''
pkgs_install = ''
files = ['/var/log/dpkg.log','/var/log/dpkg.log.1']
files.each do |file|
  if File.exist?(file)
    File.open(file) do |io|
      io.each_line do |line|
        for state in ['upgrade', 'install', 'remove'] do
          pkg = line.chomp.scan(/(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}) #{state} ([^ ]*) ([^ ]*) ([^ ]*)/).flatten
          if ! pkg.empty?
            eval("pkgs_#{state} += \"#{pkg[1]}|#{pkg[0]}|#{pkg[2]}|#{pkg[3]};\"")
          end
        end
      end
    end
  end
end

Facter.add(:upgraded_packages) { setcode { pkgs_upgrade.chomp(';') } }
Facter.add(:installed_packages) { setcode { pkgs_install.chomp(';') } }
Facter.add(:removed_packages) { setcode { pkgs_remove.chomp(';') } }
