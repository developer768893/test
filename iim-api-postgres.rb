#
# Cookbook Name:: test
# Recipe:: postgres
#
# 
#
# 
#

%w{xfsprogs xfsdump readline-devel readline-devel pgdg-ami201503-96 postgresql96 postgresql96-server postgresql96-contrib nfs-utils}.each do |pkg|
  package pkg do
    action :install
  end
end

#single.py singleton script
cookbook_file "/usr/local/bin/single.py" do
  source "chef/single.py"
  owner "root"
  group "root"
  mode "0700"
  action :create
end

template "/etc/fstab" do
  source "postgres-iimapi/fstab.erb"
  owner "root"
  group "root"
  mode "0644"
  action :create
end


#template "/etc/fstab" do
#  only_if { node.chef_environment == "production" }
#  source "postgres-iimapi/fstab.erb"
#  owner "root"
#  group "root"
#  mode "0644"
#  action :create
#  variables(
#    :postgres_backup  => 'fs-637dca2a.efs.us-east-1.amazonaws.com:/ /postgres_backup nfs4 defaults,nfsvers=4.1 0 0',
#  )
#end

template "/etc/fstab" do
  only_if { node.chef_environment == "staging" }
  source "postgres-iimapi/fstab.erb"
  owner "root"
  group "root"
  mode "0644"
  action :create
  variables(
    :postgres_backup  => 'fs-18657a51.efs.us-east-1.amazonaws.com:/ /postgres_backup nfs4 defaults,nfsvers=4.1 0 0',
  )
end

file "/root/.aws/credentials" do
  owner "root"
  group "root"
  mode "0600"
  action :create
  content "[postgres-iimapi]
aws_access_key_id = AKIAJKICJYB45FODBDAQ
aws_secret_access_key = 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
[default]
aws_access_key_id = AKIAJPQD2KRAT2JARBTA
aws_secret_access_key = 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
[tags]
aws_access_key_id = AKIAJPQD2KRAT2JARBTA
aws_secret_access_key = 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"
end

#backup chef configuration and database to S3
cookbook_file "/opt/tools/postgres_backup_s3.sh" do
  source "postgres-iimapi/postgres_backup_s3.sh"
  owner "root"
  group "root"
  mode "0700"
  action :create
end

file "/etc/cron.d/postgres_backup_s3" do
  only_if {node.chef_environment == "production"}
  manage_symlink_source true
  owner "root"
  group "root"
  mode "0644"
  action :create
  content "0 2 * * 2/2 root /usr/local/bin/single.py -c /opt/tools/postgres_backup_s3.sh"
end

bash "postgres_backup_dir" do
  only_if { node.chef_environment == "staging" || node.chef_environment == "production"}
  user "root"
  cwd "/tmp"
  not_if do ::File.exists?('/postgres_backup') end
  code <<-EOH
   mkdir /postgres_backup
   mkdir -p /opt/tools
   mount /postgres_backup
  EOH
end

bash "postgres_backup_mkdir_touch" do
  only_if { node.chef_environment == "staging" || node.chef_environment == "production"}
  user "root"
  cwd "/tmp"
  not_if do ::File.exists?('/postgres_backup/`hostname`') end
  code <<-EOH
   mkdir -p /postgres_backup/postgres/`hostname`
   chmod 775 /postgres_backup/
   chown -R postgres:root /postgres_backup/
   touch /postgres_backup/sensu_test_file_dont_remove
   chown root:root /postgres_backup/sensu_test_file_dont_remove
  EOH
end

template "/opt/tools/postgres_backup.sh" do
  only_if { node['machinename'] == "iim-api-postgres1-stage.test.com" || node['machinename'] == "iim-api-postgres1-prod.test.com" }
  source "postgres-iimapi/postgres_backup.erb"
  owner "root"
  group "root"
  mode "0755"
  action :create
end

file "/etc/cron.d/postgres_backup" do
  only_if { node['machinename'] == "iim-api-postgres1-prod.test.com" }
  manage_symlink_source true
  owner "root"
  group "root"
  mode "0644"
  action :create
  content "11 */8 * * * root /usr/local/bin/single.py -c /opt/tools/postgres_backup.sh"
end

cookbook_file "/opt/tools/delete_archive.sh" do
  only_if { node['machinename'] == "iim-api-postgres1-stage.test.com" || node['machinename'] == "iim-api-postgres1-prod.test.com" }
  source "postgres-iimapi/delete_archive.sh"
  owner "root"
  group "root"
  mode "0755"
  action :create
end

file "/etc/cron.d/delete_archive" do
  only_if { node['machinename'] == "iim-api-postgres1-stage.test.com" || node['machinename'] == "iim-api-postgres1-prod.test.com" }
  manage_symlink_source true
  owner "root"
  group "root"
  mode "0644"
  action :create
  content "15 */10 * * * root /usr/local/bin/single.py -c /opt/tools/delete_archive.sh
  "
end

cookbook_file "/etc/init.d/postgresql96" do
  only_if { node.chef_environment == "development" || node.chef_environment == "staging" || node.chef_environment == "production" }
  source "postgres-iimapi/postgresql96"
  owner "root"
  group "root"
  mode "0755"
  action :create
end

bash "postgres_data" do
  cwd "/tmp"
  not_if do ::File.exists?('/data/') end
  code <<-EOH
    mkfs.xfs -L postgres /dev/xvdb
    mkdir -p /data/
    mount -a
    chmod 700 /data/
    chown postgres:root /data/
  EOH
end

directory "/data/db" do
  owner 'postgres'
  group 'root'
  mode  '0700'
  action :create
end

directory "/data/archive" do
  owner 'postgres'
  group 'root'
  mode  '0700'
  action :create
end

template "/data/pg_hba.conf" do
  only_if { node['machinename'] == "iim-api-postgres1-dev.test.com" }
  source "postgres-iimapi/pg_hba.erb"
  owner "postgres"
  group "root"
  mode "0644"
  action :create
 end

template "/data/pg_hba.conf" do
  only_if { node['machinename'] == "iim-api-postgres1-stage.test.com" }
  source "postgres-iimapi/pg_hba.erb"
  owner "postgres"
  group "root"
  mode "0644"
  action :create
end

#template "/data/pg_hba.conf" do
#  only_if { node['machinename'] == "postgres1-prod.test.com" }
#  source "postgres-iimapi/pg_hba.erb"
#  owner "postgres"
#  group "root"
#  mode "0644"
#  action :create
#  variables(
#    :postgres_rep  => 'host    replication     postgres        10.0.1.77/32            trust',
#    :postgres_rep1 => 'host    replication     postgres        10.0.1.202/32           trust',
#    :postgres_rep2 => 'host    replication     postgres        10.0.1.56/32            trust',
#  )
#end

#template "/data/pg_hba.conf" do
#  only_if { node['machinename'] == "postgres1-repl1-prod.test.com" }
#  source "postgres-iimapi/pg_hba.erb"
#  owner "postgres"
#  group "root"
#  mode "0644"
#  action :create
#  variables(
#    :postgres_rep  => 'host    replication     postgres        10.0.1.73/32            trust',
#    :postgres_rep1 =>  '',
#    :postgres_rep2 =>  '',
#  )
#end


#bash "postgres_database_repl_stage" do
#  only_if { node['machinename'] == "postgres-iimapi1-repl1-stage.test.com" }
#  not_if do ::File.exists?('/data/db/PG_VERSION') end
#  user "postgres"
#  cwd "/tmp"
#  code <<-EOH
#     /usr/pgsql-9.6/bin/pg_basebackup -h postgres-iimapi1-stage.test.com -D /data/db/ -P -U postgres --xlog-method=stream -R
#  EOH
#end

bash "postgres_database_repl_prod_1" do
  only_if { node['machinename'] == "iim-api-postgres1-repl1-prod.test.com" }
  not_if do ::File.exists?('/data/db/PG_VERSION') end
  user "postgres"
  cwd "/tmp"
  code <<-EOH
     /usr/lib64/pgsql96/bin/pg_basebackup -h postgres-iimapi1-prod.test.com -D /data/db/ -P -U postgres --xlog-method=stream -R
  EOH
end

bash "postgres_database_init" do
  not_if do ::File.exists?('/data/db/PG_VERSION') end
  user "postgres"
  cwd "/tmp"
  code <<-EOH
    /usr/lib64/pgsql96/bin/initdb /data/db/
  EOH
end

cookbook_file "/data/db/postgresql.conf" do
  only_if { node.chef_environment == "production" }
  source "postgres-iimapi/postgresql-prod.conf"
  owner "postgres"
  group "root"
  mode "0644"
  action :create
 end

 cookbook_file "/data/db/postgresql.conf" do
  only_if { node.chef_environment == "staging" }
  source "postgres-iimapi/postgresql-dev-stage.conf"
  owner "postgres"
  group "root"
  mode "0644"
  action :create
 end

cookbook_file "/data/db/postgresql.conf" do
  only_if { node.chef_environment == "development" }
  source "postgres-iimapi/postgresql-dev-stage.conf"
  owner "postgres"
  group "root"
  mode "0644"
  action :create
 end

template "/data/db/postgresql.conf" do
   only_if { node['machinename'] == "iim-api-postgres1-repl1-stage.test.com" }
   source "postgres-iimapi/postgresql-rr.erb"
   owner "postgres"
   group "root"
   mode "0644"
   action :create
   variables(
     :postgres_listen  => '*',
     :shared_buffers => '768MB',
     :max_connections => '350',
     :effective_cache_size => '2304MB',
     :work_mem => '2246kB',
     :maintenance_work_mem => '192MB',
   )
end

template "/data/db/postgresql.conf" do
  only_if { node['machinename'] == "iim-api-postgres1-repl1-prod.test.com" }
  source "postgres/postgresql-rr.erb"
  owner "postgres"
  group "root"
  mode "0644"
  action :create
  variables(
    :postgres_listen  => '*',
    :shared_buffers => '30464MB',
    :max_connections => '1000',
    :effective_cache_size => '91392MB',
    :work_mem => '31195kB',
    :maintenance_work_mem => '2GB',
  )
end

#template "/data/db/recovery.conf" do
#  only_if { node['machinename'] == "postgres-iimapi-repl1-stage.test.com" }
#  source "postgres-iimapi/recovery.erb"
#  owner "postgres"
#  group "root"
#  mode "0644"
#  action :create
#  variables(
#  :master_repl  => 'postgres-iimapi1-stage.test.com',
#  )
#end

template "/data/db/recovery.conf" do
  only_if { node['machinename'] == "iim-api-postgres1-repl1-prod.test.com" }
  source "postgres-iimapi/recovery.erb"
  owner "postgres"
  group "root"
  mode "0644"
  action :create
  variables(
  :master_repl  => 'postgres-iimapi1-prod.test.com',
  )
end


service "postgresql96" do
  only_if { node.chef_environment == "staging" || node.chef_environment == "development" || node.chef_environment == "production" }
  action [ :enable, :start ]
end
