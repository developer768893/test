#
# Cookbook Name:: test
# Recipe:: postgres
#
# 
#
# 
#

%w{xfsprogs xfsdump readline-devel readline-devel pgdg-ami201503-96 postgresql96 postgresql96-devel postgresql96-server postgresql96-contrib}.each do |pkg|
  package pkg do
    action :install
  end
end

%w{pg dentaku}.each do |pkg|
  gem_package pkg do
  gem_binary '/opt/sensu/embedded/bin/gem'
  action :install
  end
end

###########################
#Partitions and NFS shares
###########################
bash "directory_setup" do
  user "root"
  cwd "/tmp"
  code <<-EOH
   test -d /postgres_backup || mkdir -p /postgres_backup
   test -d /opt/tools || mkdir -p /opt/tools
   test -d /data/db || mkdir -p /data/db
   test -d /data/remote_nfs || mkdir -p /data/remote_nfs
   chown postgres:postgres /data/archive_nfs || true
   chown postgres:postgres /data/archive || true 
  EOH
end

bash "postgres_data" do
  cwd "/tmp"
  not_if do ::File.exists?('/data/') end
  code <<-EOH
    mkfs.xfs -L postgres /dev/xvdb
    chmod -R 700 /data/
    chown -R postgres:root /data/
  EOH
end

bash "postgres_archive" do
  cwd "/tmp"
  only_if { node['machinename'] == "postgres1-prod.test.com" || node['machinename'] == "postgres2-prod.test.com" || node['machinename'] == "postgres3-prod.test.com" }
  not_if do ::File.exists?('/data/archive') end
  code <<-EOH
    mkdir -p /data/archive
    mkfs.xfs -L archive /dev/xvdc
    chmod 700 /data/archive
    chown postgres:postgres /data/archive
  EOH
end

bash "postgres_nfs_archive" do
  cwd "/tmp"
  only_if { node['machinename'] == "postgres1-prod.test.com" || node['machinename'] == "postgres2-prod.test.com" || node['machinename'] == "postgres3-prod.test.com" }
  not_if do ::File.exists?('/data/archive_nfs') end
  code <<-EOH
    mkdir -p /data/archive_nfs
    mkfs.xfs -L archive_nfs /dev/xvdd
    chmod 700 /data/archive_nfs
    chown postgres:postgres /data/archive_nfs
  EOH
end

template "/etc/fstab" do
  only_if { node.chef_environment == "development" }
  source "postgres/fstab.erb"
  owner "root"
  group "root"
  mode "0644"
  action :create
end

template "/etc/fstab" do
  only_if { node['machinename'] == "postgres1-repl1-stage.test.com" }
  source "postgres/fstab.erb"
  owner "root"
  group "root"
  mode "0644"
  action :create
  variables(
    :postgres_nfs_archive => 'postgres1-stage.test.com:/data/archive_nfs /data/remote_nfs nfs4 defaults,ro,sync,nfsvers=4.1 0 0',
  )
end

template "/etc/fstab" do
  only_if { node['machinename'] == "postgres2-repl1-stage.test.com" }
  source "postgres/fstab.erb"
  owner "root"
  group "root"
  mode "0644"
  action :create
  variables(
    :postgres_nfs_archive => 'postgres2-stage.test.com:/data/archive_nfs /data/remote_nfs nfs4 defaults,ro,sync,nfsvers=4.1 0 0',
  )
end

template "/etc/fstab" do
  only_if { node['machinename'] == "postgres1-stage.test.com" || node['machinename'] == "postgres2-stage.test.com" }
  source "postgres/fstab.erb"
  owner "root"
  group "root"
  mode "0644"
  action :create
  variables(
    :postgres_nfs_archive => '',
    :postgres_backup  => 'fs-9eca7cd7.efs.us-east-1.amazonaws.com:/ /postgres_backup nfs4 defaults,nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 0 0',
  )
end

template "/etc/fstab" do
  only_if { node['machinename'] == "postgres1-repl1-prod.test.com" || node['machinename'] == "postgres1-repl2-prod.test.com" || node['machinename'] == "postgres1-repl3-prod.test.com" }
  source "postgres/fstab.erb"
  owner "root"
  group "root"
  mode "0644"
  action :create
  variables(
    :postgres_nfs_archive => 'postgres1-prod.test.com:/data/archive_nfs /data/remote_nfs nfs4 defaults,ro,sync,nfsvers=4.1 0 0',
    :postgres_backup => 'fs-637dca2a.efs.us-east-1.amazonaws.com:/ /postgres_backup nfs4 defaults,nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 0 0',
  )
end

template "/etc/fstab" do
  only_if { node['machinename'] == "postgres2-repl1-prod.test.com" || node['machinename'] == "postgres2-repl2-prod.test.com" || node['machinename'] == "postgres2-repl3-prod.test.com" }
  source "postgres/fstab.erb"
  owner "root"
  group "root"
  mode "0644"
  action :create
  variables(
    :postgres_nfs_archive => 'postgres2-prod.test.com:/data/archive_nfs /data/remote_nfs nfs4 defaults,ro,sync,nfsvers=4.1 0 0',
    :postgres_backup => 'fs-637dca2a.efs.us-east-1.amazonaws.com:/ /postgres_backup nfs4 defaults,nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 0 0',
  )
end

template "/etc/fstab" do
  only_if { node['machinename'] == "postgres3-repl1-prod.test.com" || node['machinename'] == "postgres3-repl2-prod.test.com" || node['machinename'] == "postgres3-repl3-prod.test.com" }
  source "postgres/fstab.erb"
  owner "root"
  group "root"
  mode "0644"
  action :create
  variables(
    :postgres_nfs_archive => 'postgres3-prod.test.com:/data/archive_nfs /data/remote_nfs nfs4 defaults,ro,sync,nfsvers=4.1 0 0',
    :postgres_backup => 'fs-637dca2a.efs.us-east-1.amazonaws.com:/ /postgres_backup nfs4 defaults,nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 0 0',
  )
end

template "/etc/fstab" do
  only_if { node['machinename'] == "postgres1-prod.test.com" || node['machinename'] == "postgres2-prod.test.com" || node['machinename'] == "postgres3-prod.test.com" }
  source "postgres/fstab.erb"
  owner "root"
  group "root"
  mode "0644"
  action :create
  variables(
    :postgres_archive => 'LABEL=archive /data/archive xfs noatime,nobarrier,logbufs=8,logbsize=256k,allocsize=2M 0 0',
    :postgres_nfs_archive  => 'LABEL=archive_nfs /data/archive_nfs xfs noatime,nobarrier,logbufs=8,logbsize=256k,allocsize=2M 0 0',
    :postgres_backup => 'fs-637dca2a.efs.us-east-1.amazonaws.com:/ /postgres_backup nfs4 defaults,nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 0 0',
  )
end

file "/etc/exports" do
  only_if { node['machinename'] == "postgres1-prod.test.com" || node['machinename'] == "postgres2-prod.test.com" || node['machinename'] == "postgres3-prod.test.com" || node['machinename'] == "postgres1-stage.test.com" || node['machinename'] == "postgres2-stage.test.com"}
  owner "root"
  group "root"
  mode "0644"
  action :create
  content "/data/archive_nfs 10.0.0.0/16(ro,no_root_squash,sync)"
  notifies :restart, "service[nfs]", :immediately
end

execute "mount_all" do
  command 'mount -a'
end

bash "postgres_backup_mkdir_touch" do
  user "root"
  cwd "/tmp"
  code <<-EOH
  if [[ ! -d /postgres_backup/postgres/`hostname`/ ]]; then
    mkdir -p /postgres_backup/postgres/`hostname`
    chmod 775 /postgres_backup/
    chown -R postgres:root /postgres_backup/
    touch /postgres_backup/sensu_test_file_dont_remove
    chown root:root /postgres_backup/sensu_test_file_dont_remove
  fi
  EOH
end

############################
# System configs
############################
file "/root/.aws/credentials" do
  owner "root"
  group "root"
  mode "0600"
  action :create
  content "[postgres]
aws_access_key_id = AKIAJZW7FDIHAO3VUEKQ
aws_secret_access_key = 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
[default]
aws_access_key_id = AKIAJPQD2KRAT2JARBTA
aws_secret_access_key = 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
[tags]
aws_access_key_id = AKIAJPQD2KRAT2JARBTA
aws_secret_access_key = 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"
end

cookbook_file "/usr/local/bin/single.py" do
  source "chef/single.py"
  owner "root"
  group "root"
  mode "0700"
  action :create
end

###########################
#Postgres backup scripts
###########################
cookbook_file "/opt/tools/postgres_backup_s3.sh" do
  source "postgres/postgres_backup_s3.sh"
  owner "root"
  group "root"
  mode "0755"
  action :create
end

file "/etc/cron.d/postgres_backup_s3" do
  only_if {node.chef_environment == "production"}
  manage_symlink_source true
  owner "root"
  group "root"
  mode "0644"
  action :create
  content "0 2 * * 2 root /usr/local/bin/single.py -c /opt/tools/postgres_backup_s3.sh
  "
end

cookbook_file "/opt/tools/postgres_backup.sh" do
  only_if { node['machinename'] == "postgres1-stage.test.com" || node['machinename'] == "postgres1-repl1-prod.test.com" || node['machinename'] == "postgres2-repl1-prod.test.com" || node['machinename'] == "postgres3-repl1-prod.test.com" }
  source "postgres/postgres_backup.sh"
  owner "root"
  group "root"
  mode "0755"
  action :create
end

file "/etc/cron.d/postgres_backup" do
  only_if { node['machinename'] == "postgres1-stage.test.com" || node['machinename'] == "postgres1-repl1-prod.test.com" || node['machinename'] == "postgres2-repl1-prod.test.com" || node['machinename'] == "postgres3-repl1-prod.test.com" }
  manage_symlink_source true
  owner "root"
  group "root"
  mode "0644"
  action :create
  content "11 */8 * * * root /usr/local/bin/single.py -c /opt/tools/postgres_backup.sh
  "
end

cookbook_file "/opt/tools/delete_archive.sh" do
  only_if { node['machinename'] == "postgres1-stage.test.com" || node['machinename'] == "postgres1-prod.test.com" || node['machinename'] == "postgres2-prod.test.com" || node['machinename'] == "postgres3-prod.test.com" }
  source "postgres/delete_archive.sh"
  owner "root"
  group "root"
  mode "0755"
  action :create
end

file "/etc/cron.d/delete_archive" do
  only_if { node['machinename'] == "postgres1-stage.test.com" || node['machinename'] == "postgres1-prod.test.com" || node['machinename'] == "postgres2-prod.test.com" || node['machinename'] == "postgres3-prod.test.com"}
  manage_symlink_source true
  owner "root"
  group "root"
  mode "0644"
  action :create
  content "15 */10 * * * root /usr/local/bin/single.py -c /opt/tools/delete_archive.sh
  "
end

###########################
#Postgres configs
###########################
template "/data/pg_hba.conf" do
  only_if { node['machinename'] == "postgres1-dev.test.com" }
  source "postgres/pg_hba.erb"
  owner "postgres"
  group "root"
  mode "0644"
  action :create
end

template "/data/pg_hba.conf" do
  only_if { node['machinename'] == "postgres1-repl1-stage.test.com" }
  source "postgres/pg_hba.erb"
  owner "postgres"
  group "root"
  mode "0644"
  action :create
  variables(
    :postgres_rep  => 'host    replication     postgres        10.0.17.133/32            trust',
  )
end

template "/data/pg_hba.conf" do
  only_if { node['machinename'] == "postgres1-stage.test.com" }
  source "postgres/pg_hba.erb"
  owner "postgres"
  group "root"
  mode "0644"
  action :create
  variables(
    :postgres_rep  => 'host    replication     postgres        10.0.17.91/32            trust',
  )
end

template "/data/pg_hba.conf" do
  only_if { node['machinename'] == "postgres2-repl1-stage.test.com" }
  source "postgres/pg_hba.erb"
  owner "postgres"
  group "root"
  mode "0644"
  action :create
  variables(
    :postgres_rep  => 'host    replication     postgres        10.0.17.154/32            trust',
  )
end

template "/data/pg_hba.conf" do
  only_if { node['machinename'] == "postgres2-stage.test.com" }
  source "postgres/pg_hba.erb"
  owner "postgres"
  group "root"
  mode "0644"
  action :create
  variables(
    :postgres_rep  => 'host    replication     postgres        10.0.17.19/32            trust',
  )
end

template "/data/pg_hba.conf" do
  only_if { node['machinename'] == "postgres1-prod.test.com" }
  source "postgres/pg_hba.erb"
  owner "postgres"
  group "root"
  mode "0644"
  action :create
  variables(
    :postgres_rep  => 'host    replication     postgres        10.0.1.77/32            trust',
    :postgres_rep1 => 'host    replication     postgres        10.0.1.202/32           trust',
    :postgres_rep2 => 'host    replication     postgres        10.0.1.56/32            trust',
  )
end

template "/data/pg_hba.conf" do
  only_if { node['machinename'] == "postgres1-repl1-prod.test.com" }
  source "postgres/pg_hba.erb"
  owner "postgres"
  group "root"
  mode "0644"
  action :create
  variables(
    :postgres_rep  => 'host    replication     postgres        10.0.1.73/32            trust',
  )
end

template "/data/pg_hba.conf" do
  only_if { node['machinename'] == "postgres1-repl2-prod.test.com" }
  source "postgres/pg_hba.erb"
  owner "postgres"
  group "root"
  mode "0644"
  action :create
  variables(
    :postgres_rep  => 'host    replication     postgres        10.0.1.73/32            trust',
  )
end

template "/data/pg_hba.conf" do
  only_if { node['machinename'] == "postgres1-repl3-prod.test.com" }
  source "postgres/pg_hba.erb"
  owner "postgres"
  group "root"
  mode "0644"
  action :create
  variables(
    :postgres_rep  => 'host    replication     postgres        10.0.1.73/32            trust',
  )
end

template "/data/pg_hba.conf" do
  only_if { node['machinename'] == "postgres2-prod.test.com" }
  source "postgres/pg_hba.erb"
  owner "postgres"
  group "root"
  mode "0644"
  action :create
  variables(
    :postgres_rep  => 'host    replication     postgres        10.0.1.193/32            trust',
    :postgres_rep1 => 'host    replication     postgres        10.0.1.101/32            trust',
    :postgres_rep2 => 'host    replication     postgres        10.0.1.16/32            trust',
  )
end

template "/data/pg_hba.conf" do
  only_if { node['machinename'] == "postgres2-repl1-prod.test.com" }
  source "postgres/pg_hba.erb"
  owner "postgres"
  group "root"
  mode "0644"
  action :create
  variables(
    :postgres_rep  => 'host    replication     postgres        10.0.1.69/32            trust',
  )
end

template "/data/pg_hba.conf" do
  only_if { node['machinename'] == "postgres2-repl2-prod.test.com" }
  source "postgres/pg_hba.erb"
  owner "postgres"
  group "root"
  mode "0644"
  action :create
  variables(
    :postgres_rep  => 'host    replication     postgres        10.0.1.69/32            trust',
  )
end

template "/data/pg_hba.conf" do
  only_if { node['machinename'] == "postgres2-repl3-prod.test.com" }
  source "postgres/pg_hba.erb"
  owner "postgres"
  group "root"
  mode "0644"
  action :create
  variables(
    :postgres_rep  => 'host    replication     postgres        10.0.1.69/32            trust',
  )
end
template "/data/pg_hba.conf" do
  only_if { node['machinename'] == "postgres3-prod.test.com" }
  source "postgres/pg_hba.erb"
  owner "postgres"
  group "root"
  mode "0644"
  action :create
  variables(
    :postgres_rep  => 'host    replication     postgres        10.0.1.151/32            trust',
    :postgres_rep1 => 'host    replication     postgres        10.0.1.115/32            trust',
    :postgres_rep2 => 'host    replication     postgres        10.0.1.105/32            trust',
  )
end

template "/data/pg_hba.conf" do
  only_if { node['machinename'] == "postgres3-repl1-prod.test.com" }
  source "postgres/pg_hba.erb"
  owner "postgres"
  group "root"
  mode "0644"
  action :create
  variables(
    :postgres_rep  => 'host    replication     postgres        10.0.1.55/32            trust',
  )
end

template "/data/pg_hba.conf" do
  only_if { node['machinename'] == "postgres3-repl2-prod.test.com" }
  source "postgres/pg_hba.erb"
  owner "postgres"
  group "root"
  mode "0644"
  action :create
  variables(
    :postgres_rep  => 'host    replication     postgres        10.0.1.55/32            trust',
  )
end

template "/data/pg_hba.conf" do
  only_if { node['machinename'] == "postgres3-repl3-prod.test.com" }
  source "postgres/pg_hba.erb"
  owner "postgres"
  group "root"
  mode "0644"
  action :create
  variables(
    :postgres_rep  => 'host    replication     postgres        10.0.1.55/32            trust',
  )
end

bash "postgres_database_repl_stage" do
  only_if { node['machinename'] == "postgres1-repl1-stage.test.com" }
  not_if do ::File.exists?('/data/db/PG_VERSION') end
  user "postgres"
  cwd "/tmp"
  code <<-EOH
     /usr/pgsql-9.6/bin/pg_basebackup -h postgres1-stage.test.com -D /data/db/ -P -U postgres --xlog-method=stream -R
  EOH
end

bash "postgres_database_repl_stage" do
  only_if { node['machinename'] == "postgres2-repl1-stage.test.com" }
  not_if do ::File.exists?('/data/db/PG_VERSION') end
  user "postgres"
  cwd "/tmp"
  code <<-EOH
     /usr/pgsql-9.6/bin/pg_basebackup -h postgres2-stage.test.com -D /data/db/ -P -U postgres --xlog-method=stream -R
  EOH
end

bash "postgres_database_repl_prod_1" do
  only_if { node['machinename'] == "postgres1-repl1-prod.test.com" || node['machinename'] == "postgres1-repl2-prod.test.com" || node['machinename'] == "postgres1-repl3-prod.test.com" }
  not_if do ::File.exists?('/data/db/PG_VERSION') end
  user "postgres"
  cwd "/tmp"
  code <<-EOH
     /usr/pgsql-9.6/bin/pg_basebackup -h postgres1-prod.test.com -D /data/db/ -P -U postgres --xlog-method=stream -R
  EOH
end

bash "postgres_database_repl_prod_2" do
  only_if { node['machinename'] == "postgres2-repl1-prod.test.com" || node['machinename'] == "postgres2-repl2-prod.test.com" || node['machinename'] == "postgres2-repl3-prod.test.com" }
  not_if do ::File.exists?('/data/db/PG_VERSION') end
  user "postgres"
  cwd "/tmp"
  code <<-EOH
     /usr/pgsql-9.6/bin/pg_basebackup -h postgres2-prod.test.com -D /data/db/ -P -U postgres --xlog-method=stream -R
  EOH
end

bash "postgres_database_repl_prod_3" do
  only_if { node['machinename'] == "postgres3-repl1-prod.test.com" || node['machinename'] == "postgres3-repl2-prod.test.com" || node['machinename'] == "postgres3-repl3-prod.test.com" }
  not_if do ::File.exists?('/data/db/PG_VERSION') end
  user "postgres"
  cwd "/tmp"
  code <<-EOH
     /usr/pgsql-9.6/bin/pg_basebackup -h postgres3-prod.test.com -D /data/db/ -P -U postgres --xlog-method=stream -R
  EOH
end

bash "postgres_database_init" do
  not_if do ::File.exists?('/data/db/PG_VERSION') end
  user "postgres"
  cwd "/tmp"
  code <<-EOH
    /usr/pgsql-9.6/bin/initdb /data/db/
  EOH
end

cookbook_file "/data/db/postgresql.conf" do
  only_if { node['machinename'] == "postgres1-stage.test.com" || node['machinename'] == "postgres2-stage.test.com" || node['machinename'] == "postgres1-dev.test.com"  }
  source "postgres/postgresql-dev-stage.conf"
  owner "postgres"
  group "root"
  mode "0644"
  action :create
end

template "/data/db/postgresql.conf" do
   only_if { node['machinename'] == "postgres1-repl1-stage.test.com" }
   source "postgres/postgresql-rr.erb"
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
  only_if { node['machinename'] == "postgres2-repl1-stage.test.com" }
  source "postgres/postgresql-rr.erb"
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

cookbook_file "/data/db/postgresql.conf" do
  only_if { node['machinename'] == "postgres1-prod.test.com" || node['machinename'] == "postgres2-prod.test.com" || node['machinename'] == "postgres3-prod.test.com" }
  source "postgres/postgresql-prod.conf"
  owner "postgres"
  group "root"
  mode "0644"
  action :create
end

template "/data/db/postgresql.conf" do
  only_if { node['machinename'] == "postgres1-repl1-prod.test.com" || node['machinename'] == "postgres1-repl2-prod.test.com" || node['machinename'] == "postgres1-repl3-prod.test.com" || node['machinename'] == "postgres2-repl1-prod.test.com" || node['machinename'] == "postgres2-repl2-prod.test.com" || node['machinename'] == "postgres2-repl3-prod.test.com" || node['machinename'] == "postgres3-repl1-prod.test.com" || node['machinename'] == "postgres3-repl2-prod.test.com" || node['machinename'] == "postgres3-repl3-prod.test.com"}
  source "postgres/postgresql-rr.erb"
  owner "postgres"
  group "root"
  mode "0644"
  action :create
  variables(
    :postgres_listen  => '*',
    :shared_buffers => '30464MB',
    :max_connections => '2000',
    :effective_cache_size => '91392MB',
    :work_mem => '31195kB',
    :maintenance_work_mem => '2GB',
  )
end

template "/data/db/recovery.conf" do
  only_if { node['machinename'] == "postgres1-repl1-stage.test.com" }
  source "postgres/recovery.erb"
  owner "postgres"
  group "root"
  mode "0644"
  action :create
  variables(
  :master_repl  => 'postgres1-stage.test.com',
  )
end

template "/data/db/recovery.conf" do
  only_if { node['machinename'] == "postgres2-repl1-stage.test.com" }
  source "postgres/recovery.erb"
  owner "postgres"
  group "root"
  mode "0644"
  action :create
  variables(
  :master_repl  => 'postgres2-stage.test.com',
  )
end

template "/data/db/recovery.conf" do
  only_if { node['machinename'] == "postgres1-repl1-prod.test.com" || node['machinename'] == "postgres1-repl2-prod.test.com" || node['machinename'] == "postgres1-repl3-prod.test.com" }
  source "postgres/recovery.erb"
  owner "postgres"
  group "root"
  mode "0644"
  action :create
  variables(
  :master_repl  => 'postgres1-prod.test.com',
  )
end

template "/data/db/recovery.conf" do
  only_if { node['machinename'] == "postgres2-repl1-prod.test.com" || node['machinename'] == "postgres2-repl2-prod.test.com" || node['machinename'] == "postgres2-repl3-prod.test.com" }
  source "postgres/recovery.erb"
  owner "postgres"
  group "root"
  mode "0644"
  action :create
  variables(
  :master_repl  => 'postgres2-prod.test.com',
  )
end

template "/data/db/recovery.conf" do
  only_if { node['machinename'] == "postgres3-repl1-prod.test.com" || node['machinename'] == "postgres3-repl2-prod.test.com" || node['machinename'] == "postgres3-repl3-prod.test.com" }
  source "postgres/recovery.erb"
  owner "postgres"
  group "root"
  mode "0644"
  action :create
  variables(
  :master_repl  => 'postgres3-prod.test.com',
  )
end

file "/etc/init.d/postgresql-9.6.rpmsave" do
  action :delete
end

file "/etc/init.d/postgresql-9.6" do
  action :delete
end

cookbook_file "/etc/init.d/postgresql96" do
  source "postgres/postgresql96"
  owner "root"
  group "root"
  mode "0755"
  action :create
end

##########
#Services
##########
service "nfs" do
  action [ :enable, :start ]
end

service "postgresql96" do
  action [ :enable, :start ]
end
