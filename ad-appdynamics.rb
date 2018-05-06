#
# Cookbook Name:: test
# Recipe:: ad server appdynamics node 
#
# 
#
# 
#

#appdynamics node
%w{test-appdynamics-java-agent appdynamics-machine-agent perl}.each do |pkg|
  package pkg do
    action :install
  end
end

bash 'appdynamics_config_file' do
  code <<-EOH
    echo "This server is an appdynamics node." > /opt/adserver/etc/appdynamics_node
  EOH
end

template "/opt/appdynamics/ja/latest/conf/controller-info.xml" do
  source "appdynamics/ja/controller-info.xml"
  owner "root"
  group "root"
  mode "0644"
  action :create
  variables(
    :machinename => node['machinename'],
    :role => 'ad',
  )
  notifies :restart, "service[adserver]", :delayed
end

template "/etc/appdynamics/machine-agent/controller-info.xml" do
  source "appdynamics/ma/controller-info.xml"
  owner "appdynamics-machine-agent"
  group "appdynamics-machine-agent"
  mode "0644"
  action :create
  variables(
    :machinename => node['machinename'],
    :role => 'ad',
  )
  notifies :restart, "service[appdynamics-machine-agent]", :delayed
end

cookbook_file "/etc/logstash/conf.d/ad" do
  source "logstash/ad"
  owner "root"
  group "root"
  mode "0644"
  action :create
  notifies :restart, "service[logstash]", :delayed
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
  content "*/10 * * * * root /opt/tools/aws-tags-appdynamics.sh
  "
end

file "/etc/cron.d/aws-chef-appdynamics" do
  manage_symlink_source true
  owner "root"
  group "root"
  mode "0644"
  action :create
  content "* */5 * * * root /usr/bin/chef-client -N `hostname` -r 'role[ad],recipe[test::logstash],recipe[test::ad-appdynamics]' -E alpha
  "
end

service "appdynamics-machine-agent" do
  action [ :enable, :start ]
  ignore_failure true
end

service "logstash" do
  action [ :start ]
end

