if File.exists?('/usr/bin/apt-get')
  # What does this do?
  # It simulates an apt-get upgrade, takes the output and finds all the lines starting with Inst and gets the package name from it.
  packages =  %x{/usr/bin/apt-get -s -o Debug::NoLocking=true upgrade}.scan(/^Inst ([^ ]*)/)
  Facter.add('upgrades_available') { setcode { packages.size } }
  Facter.add('upgrades_available_packages') { setcode { packages.join(',') } }
end
