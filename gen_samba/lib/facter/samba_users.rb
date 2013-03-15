if File.exists?('/usr/bin/pdbedit')
  fact0 = ''
  fact1 = ''
  %x{/usr/bin/pdbedit -L}.scan(/([^:]*):([^:]*):(.*)/).each do |userline|
    fact0 = fact0 + userline[0].gsub("\n",'') + ';'
    fact1 = fact1 + userline[2] + ';'
  end
  Facter.add(:samba_users) { setcode { fact0.chomp(';') } }
  Facter.add(:samba_users_full_names) { setcode { fact1.chomp(';') } }
end

