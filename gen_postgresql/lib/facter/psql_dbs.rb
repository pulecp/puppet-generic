begin
  if File.exist?("/etc/init.d/postgresql")
    dbs = %x{cd /tmp; /usr/bin/sudo -u postgres /usr/bin/psql -A -F ';' -t -c '\\l' | /usr/bin/awk -F';' '{print $1}' | /bin/grep -v =}.split("\n").join(';')
    Facter.add("psql_dbs") do
      setcode do
        dbs
      end
    end
  end
rescue
# do nothing
end
