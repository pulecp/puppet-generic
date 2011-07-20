File.exist?("/etc/puppet/nomonitoring") ? has_file = false : has_file = true
Facter.add("monitoring") do
	setcode do
		has_file
	end
end
File.exist?("/etc/puppet/nomonitoringsms") ? has_file = false : has_file = true
Facter.add("monitoring_sms") do
	setcode do
		has_file
	end
end
