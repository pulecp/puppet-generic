begin
  if File.exist?("/etc/init.d/postgresql")
    users = %x{cd /tmp; /usr/bin/sudo -u postgres /usr/bin/psql -A -F ';' -t -c '\\du' | /usr/bin/awk -F ';' '{print $1}'}.split("\n").join(';')
    Facter.add("psql_users") do
      setcode do
        users
      end
    end
  end
rescue
# do nothing
end
