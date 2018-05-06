#
# Cookbook Name:: test
# Recipe:: rtb appdynamics node
#
# 
#
# 
#

%w{appdynamics-machine-agent test-appdynamics-java-agent }.each do |pkg|
  package pkg do
  action :install
 end
end

template "/etc/appdynamics/machine-agent/controller-info.xml" do
  source "appdynamics/ma/controller-info.xml"
  owner "appdynamics-machine-agent"
  group "appdynamics-machine-agent"
  mode "0644"
  action :create
  variables(
    :machinename => node['machinename'],
    :role => 'rtb',
  )
  notifies :restart, "service[appdynamics-machine-agent]", :delayed
end

template "/opt/appdynamics/ja/latest/conf/controller-info.xml" do
  source "appdynamics/ja/controller-info.xml"
  owner "root"
  group "root"
  mode "0644"
  action :create
  variables(
    :machinename => node['machinename'],
    :role => 'rtb',
  )
  notifies :restart, "service[rtb]", :delayed
end

file "/opt/rtb/etc/appdynamics_node" do
  owner "root"
  group "root"
  mode "0644"
  action :create
  content " "
end

cookbook_file "/opt/tools/aws-tags-appdynamics.sh" do
  source "appdynamics/aws-tags-appdynamics.sh"
  owner "root"
  group "root"
  mode "0755"
  action :create
end

file "/etc/cron.d/aws-tags-appdynamics" do
  manage_symlink_source true
  owner "root"
  group "root"
  mode "0644"
  action :create
  content "34,05 * * * * root /opt/tools/aws-tags-appdynamics.sh
  "
end

file "/etc/cron.d/aws-chef-appdynamics" do
  manage_symlink_source true
  owner "root"
  group "root"
  mode "0644"
  action :create
  content "* */5 * * * root /usr/bin/chef-client -N `hostname` -r 'role[rtb],recipe[test::logstash],recipe[test::rtb-appdynamics]' -E alpha
  "
end

cookbook_file "/etc/logstash/conf.d/rtb" do
  source "logstash/rtb"
  owner "root"
  group "root"
  mode "0644"
  action :create
  notifies :restart, "service[logstash]", :delayed
end

service "rtb" do
  action [ :enable, :start ]
end

service "logstash" do
  action [ :start ]
  ignore_failure true
end

service "appdynamics-machine-agent" do
  action [ :enable, :start ]
  ignore_failure true
end

