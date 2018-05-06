#
# Cookbook Name:: test
# Recipe:: sensu-client
#
# 
#
# 
#

package "gcc-c++" do
    action :install
end

package "nmap" do
    action :install
end

package "sysstat" do
    action :install
end

package "sensu" do
  action :upgrade
  notifies :restart, "service[sensu-client]", :delayed
  ignore_failure true
end

package "test-sensu-plugins" do
  action :upgrade
  ignore_failure true
end

template "/etc/sensu/conf.d/config.json" do
  only_if { node.chef_environment == "development" }
  source "config-json.erb"
  owner 'sensu'
  group 'sensu'
  action :create
  variables(
    :machinename => node['machinename'],
    :ipaddress => node['ipaddress'],
    :role => node['roles'],
    :environment => 'development',
  )
  notifies :restart, "service[sensu-client]", :delayed
end

template "/etc/sensu/conf.d/config.json" do
  only_if { node.chef_environment == "staging" }
  source "config-json.erb"
  owner 'sensu'
  group 'sensu'
  action :create
  variables(
    :machinename => node['machinename'],
    :ipaddress => node['ipaddress'],
    :role => node['roles'],
    :environment => 'staging',
  )
  notifies :restart, "service[sensu-client]", :delayed
end

template "/etc/sensu/conf.d/config.json" do
  only_if { node.chef_environment == "alpha" }
  source "config-json.erb"
  owner 'sensu'
  group 'sensu'
  action :create
  variables(
    :machinename => node['machinename'],
    :ipaddress => node['ipaddress'],
    :role => node['roles'],
    :environment => 'alpha',
  )
  notifies :restart, "service[sensu-client]", :delayed
end

template "/etc/sensu/conf.d/config.json" do
  only_if { node.chef_environment == "production" && node['machinename'] != "sensu1-prod.test.com" && node['machinename'] != "chef.test.com" && node['machinename'] != "bamboo1-prod.test.com" }
  source "config-json.erb"
  owner 'sensu'
  group 'sensu'
  action :create
  variables(
    :machinename => node['machinename'],
    :ipaddress => node['ipaddress'],
    :role => node['roles'],
    :environment => 'production',
  )
  notifies :restart, "service[sensu-client]", :delayed
end

template "/etc/sensu/conf.d/config.json" do
  only_if { node['machinename'] == "sensu1-prod.test.com" || node['machinename'] == "chef.test.com" || node['machinename'] == "bamboo1-prod.test.com"}
  source "config-json.erb"
  owner 'sensu'
  group 'sensu'
  action :create
  variables(
    :machinename => node['machinename'],
    :ipaddress => node['ipaddress'],
    :role => node['roles'],
    :environment => 'production',
    :aws_id_key=> 'AKIAITQJTVLBPA4JKRMA',
    :aws_secret_key=> '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',
  )
end

cookbook_file "/etc/sudoers.d/sensu" do
  source "sensu/sudoers"
  owner "root"
  group "root"
  action :create
end

cookbook_file "/etc/default/sensu" do
  source "sensu/sensu"
  owner "root"
  group "root"
  action :create
end

cookbook_file "/etc/init.d/sensu-service" do
  source "sensu/sensu-service"
  owner "root"
  group "root"
  action :create
end

#client.pem giving sensu read access to the file
file "/etc/chef/client.pem" do
  owner "root"
  group "sensu"
  mode "0640"
  action :create
end

#Inspec

#%w{rb-readline}.each do |pkg|
#  gem_package pkg do
#  gem_binary '/opt/sensu/embedded/bin/gem'
#  version '0.5.3'
#  action :remove
#  end
#end

%w{rb-readline}.each do |pkg|
  gem_package pkg do
  gem_binary '/opt/sensu/embedded/bin/gem'
  version '0.5.5'
  action :install
  end
end

%w{net-ssh}.each do |pkg|
  gem_package pkg do
  gem_binary '/opt/sensu/embedded/bin/gem'
  version '3.2.0'
  action :remove
  end
end

%w{net-ssh}.each do |pkg|
  gem_package pkg do
  gem_binary '/opt/sensu/embedded/bin/gem'
  version '4.1.0'
  action :install
  end
end

%w{inspec}.each do |pkg|
  gem_package pkg do
  gem_binary '/opt/sensu/embedded/bin/gem'
  version '2.1.0'
  action :install
  end
end

#giving Sensu access to Inspec
directory "/opt/sensu/.inspec" do
  owner "sensu"
  group "sensu"
  mode "0755"
  action :create
end

bash "inspec_directory" do
  cwd "/tmp"
  not_if do ::File.exists?('/etc/inspec/controls/') end
  code <<-EOH
    mkdir -p /etc/inspec/controls/
  EOH
end

directory "/etc/inspec/controls/" do
  owner "sensu"
  group "sensu"
  mode "0755"
  action :create
end

cookbook_file "/etc/inspec/controls/attributes.yml" do
  source "inspec/attributes.yml"
  owner "sensu"
  group "sensu"
  action :create
end

cookbook_file "/etc/sensu/conf.d/rabbitmq.json" do
only_if { node['ec2']['placement_availability_zone'].chop == "us-east-1"}
  source "sensu/rabbitmq.json"
  owner "sensu"
  group "sensu"
  action :create
  notifies :restart, "service[sensu-client]", :delayed
end

cookbook_file "/etc/sensu/conf.d/rabbitmq.json" do
only_if { node['ec2']['placement_availability_zone'].chop == "us-west-2"}
  source "sensu/rabbitmq-w.json"
  owner "sensu"
  group "sensu"
  action :create
  notifies :restart, "service[sensu-client]", :delayed
end

service "sensu-client" do
  only_if { node['uptime_seconds'] >= 7200 }
  action [ :enable, :start ]
  ignore_failure true
end
