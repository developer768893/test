#
# Cookbook Name:: test
# Recipe:: chronograf
#
# 
#
# 
#

cookbook_file "/etc/yum.repos.d/influxdb.repo" do
  source "repos/influxdb.repo"
  owner "root"
  group "root"
  mode "0644"
  action :create
end

%w{chronograf}.each do |pkg|
  package pkg do
    action :upgrade
    notifies :restart, "service[chronograf]", :delayed
  end
end

cookbook_file "/opt/chronograf/config.toml" do
  source "influxdb/config.toml"
  owner "chronograf"
  group "chronograf"
  mode "0664"
  action :create
  notifies :restart, "service[chronograf]", :delayed
end

service "chronograf" do
  action [ :enable, :start ]
end

