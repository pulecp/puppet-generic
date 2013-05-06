fact = ''
num_dbs = 0
if File.exists?('/usr/sbin/mysqld')
  %x{/usr/sbin/service mysql status}
  if $? == 0
    if File.exists?('/usr/bin/mysql')
      # We get all the data at once, so
      # 1. Less forking
      # 2. way quicker
      tables_data = %x{/usr/bin/mysql --defaults-file=/etc/mysql/debian.cnf -D information_schema -e 'select TABLE_SCHEMA, DATA_LENGTH, INDEX_LENGTH from TABLES;'}.split("\n")[1..-1]
      # Setup some veriables we need in the loop
      num_tables = 0
      size_tables = 0
      db=''
      if ! tables_data.nil?
        tables_data.each do |data|
          data = data.split("\t")
          if ['mysql','information_schema','performance_schema'].include? data[0]
            # We don't want info on those databases
            next
          end
          if db == '' then
            # we need some magic for the first db
            db = data[0]
            num_dbs += 1
            num_tables = 0
          end
          if db != data[0] then
            fact += "#{db}|#{num_tables}|#{size_tables/ (1024*1024)};"
            db = data[0]
            num_dbs += 1
            num_tables = 0
            size_tables = 0
          end
          num_tables += 1
          size_tables += (data[1].to_i + data[2].to_i)
        end
      end
      # To add the data of the last DB to the fact...
      fact += "#{db}|#{num_tables}|#{size_tables/ (1024*1024)};"
    end
  end
end

Facter.add(:mysql_databases_num) { setcode { num_dbs } }
Facter.add(:mysql_databases) { setcode { fact.chomp(';') } }
