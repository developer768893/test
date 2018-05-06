#
# Cookbook Name:: test
# Recipe:: redis-dmp-west
#
# 
#
# 
#

%w{redis nfs-utils}.each do |pkg|
  package pkg do
    action :install
  end
end

%w{redis}.each do |pkg|
  gem_package pkg do
  gem_binary '/opt/sensu/embedded/bin/gem'
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
  only_if { node.chef_environment == "production" }
  source "redis/fstab.erb"
  owner "root"
  group "root"
  mode "0644"
  action :create
  variables(
    :redis_swap    => '/var/lib/redis/swapfile1 none swap  defaults    0   0',
    :redis_dir     => '/dev/xvdb   /var/lib/redis ext4 defaults        0   2',
    :redis_backup  => 'fs-9a78b733.efs.us-west-2.amazonaws.com:/ /redis_backup nfs4 defaults,nfsvers=4.1 0 0',
  )
end

bash "redis_var_lib_redis" do
  cwd "/tmp"
  only_if { node.chef_environment == "production" }
  code <<-EOH
   if [ ! -f /tmp/redis ]; then
     mkfs.ext4 -F /dev/xvdb
     mount /var/lib/redis
     touch /tmp/redis
     chown -R redis.redis /var/lib/redis
   fi
  EOH
end

bash "redis_system_params" do
  user "root"
  cwd "/tmp"
  code <<-EOH
  sysctl -w vm.overcommit_memory=1
  echo never > /sys/kernel/mm/transparent_hugepage/enabled
  sysctl -w net.core.somaxconn=65535
  echo 16000 > /proc/sys/net/ipv4/tcp_max_syn_backlog
  EOH
end

bash "redis-swaps" do
  user "root"
  cwd "/tmp"
  code <<-EOH
  if [ -f /var/lib/redis/swapfile1 ]; then
    echo "/var/lib/redis/swapfile1 already exists"
    echo 100 > /proc/sys/vm/swappiness
    swapon -a
  else
    fallocate -l 110G /var/lib/redis/swapfile1
    chmod 600 /var/lib/redis/swapfile1
    mkswap /var/lib/redis/swapfile1
    swapon -a
  fi
  EOH
end

bash "redis_backup_dir" do
  cwd "/tmp"
  not_if do ::File.exists?('/tmp/backup') end
  code <<-EOH
   mkdir /redis_backup
   mkdir -p /opt/tools
   mount /redis_backup
   touch /tmp/backup
  EOH
end

cookbook_file "/opt/tools/redis-trib.rb" do
  source "redis/redis-trib.rb"
  owner "root"
  group "root"
  mode "0755"
  action :create
end

cookbook_file "/etc/security/limits.d/95-redis.conf" do
  source "redis/95-redis.conf"
  owner "root"
  group "root"
  mode "0644"
  action :create
end

template "/opt/tools/redis_backup.sh" do
  source "redis/redis_backup.erb"
  owner "root"
  group "root"
  mode "0755"
  action :create
  variables(
    :machinename => node['machinename'],
  )
end

file "/etc/cron.d/redis_backup" do
  manage_symlink_source true
  owner "root"
  group "root"
  mode "0644"
  action :create
  content "11 8 * * * root /usr/local/bin/single.py -c /opt/tools/redis_backup.sh
  "
end

template "/etc/redis.conf" do
  only_if { node.chef_environment == "production" }
  source "redis/redis.erb"
  owner "root"
  group "root"
  mode "0644"
  action :create
  variables(
    :redis_maxmemory  => '11gb',
  )
end

service "redis" do
  action [ :enable, :start ]
end

