File.exist?("/etc/puppet/nomonitoring") ? (File.open('/etc/puppet/nomonitoring').read.strip == 'FORCE' ? monitoring = 'force_off' : monitoring = false) : monitoring = true
Facter.add("monitoring") do
        setcode do
                monitoring
        end
end
File.exist?("/etc/puppet/nomonitoringsms") ? monitoringsms = false : monitoringsms = true
Facter.add("monitoring_sms") do
        setcode do
                monitoringsms
        end
end
