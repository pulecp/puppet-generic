File.exist?("/etc/puppet/nomonitoring") ? has_monitoringfile = false : has_monitoringfile = true
Facter.add("monitoring") do
	setcode do
		has_monitoringfile
	end
end
File.exist?("/etc/puppet/nomonitoringsms") ? has_monitoringsmsfile = false : has_monitoringsmsfile = true
Facter.add("monitoring_sms") do
	setcode do
		has_monitoringsmsfile
	end
end
