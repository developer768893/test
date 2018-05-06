#
# Cookbook Name:: test
# Recipe:: influxdb
#
# 
#
# 
#

%w{xfsprogs xfsdump readline-devel readline-devel influxdb kapacitor}.each do |pkg|
  package pkg do
    action :install
  end
end

cookbook_file "/etc/yum.repos.d/influxdb.repo" do
  source "repos/influxdb.repo"
  owner "root"
  group "root"
  mode "0644"
  action :create
end

template "/etc/fstab" do
  only_if { node.chef_environment == "production" }
  source "influxdb/fstab.erb"
  owner "root"
  group "root"
  mode "0644"
  action :create
  variables(
    :influxdb_dir  => 'LABEL=influxdb /data xfs noatime,nobarrier,logbufs=8,logbsize=256k,allocsize=2M 0 0',
  )
end

bash "influxdb_data" do
  not_if do ::File.exists?('/data') end
  cwd "/tmp"
  code <<-EOH
     mkfs.xfs -L influxdb /dev/xvdb
     mkdir -p /data
     mount -a
     chmod 755 /data
     chown -R influxdb.influxdb /data
  EOH
end

cookbook_file "/etc/influxdb/influxdb.conf" do
  source "influxdb/influxdb.conf"
  owner "root"
  group "root"
  mode "0644"
  action :create
  notifies :restart, "service[influxdb]", :delayed
end

service "kapacitor" do
  action [ :enable, :start ]
end

service "influxdb" do
  action [ :enable, :start ]
end

