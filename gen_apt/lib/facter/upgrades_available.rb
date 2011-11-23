if File.exists?('/usr/bin/apt-get')
  # What does this do?
  # It simulates an apt-get upgrade, takes the output and finds all the lines starting with Inst and shows the size of it.
  Facter.add('upgrades_available') { setcode { %x{/usr/bin/apt-get -s -o Debug::NoLocking=true upgrade}.grep(/^Inst/).size } }
end
