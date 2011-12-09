# puppetpubpem.rb

Facter.add("puppetpubpem") do
	setcode do
		value = nil
		if FileTest.file?(["/var/lib/puppet/ssl/public_keys/",Facter.value(:fqdn),".pem"].join)
			File.open(["/var/lib/puppet/ssl/public_keys/",Facter.value(:fqdn),".pem"].join) { |f|
				value = f.read
			}
		end
		value.gsub!(/\n/, ";")
	end
end
