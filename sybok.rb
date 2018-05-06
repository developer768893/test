#
# Cookbook Name:: test
# Recipe:: sybok
#
# 
#
# 
#

%w{test-jetty-9 java-1.8.0-openjdk }.each do |pkg|
  package pkg do
    action :install
  end
end

yum_package "test-sybok" do
    action :upgrade
    allow_downgrade true
end

cookbook_file "/etc/logstash/conf.d/sybok" do
  source "logstash/sybok"
  owner "root"
  group "root"
  mode "0644"
  action :create
  notifies :restart, "service[logstash]", :delayed
end

service "jetty" do
  action [ :enable, :start ]
end

