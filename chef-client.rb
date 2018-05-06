#
# Cookbook Name:: test
# Recipe:: chef-client
#
# 
#
# 
#

#if not 777 sensu can't check logs within the dir.
directory "/var/log/chef" do
  action :create
  owner "root"
  group "root"
  mode "0777"
end

cookbook_file "/etc/chef/validation.pem" do
  source "chef/validation.pem"
  mode 0400
  owner "root"
  group "root"
end

cookbook_file "/etc/init.d/chef-client" do
  source "chef/chef-client"
  mode 0755
  owner "root"
  group "root"
end

cookbook_file "/etc/chef/client.rb" do
  source "chef/client.rb"
  mode 0644
  owner "root"
  group "root"
end

file "/var/chef/environment" do
  only_if { node.chef_environment == "development" }
  owner "root"
  group "root"
  mode "0444"
  action :create
  content "development"
end

file "/var/chef/environment" do
  only_if { node.chef_environment == "staging" }
  owner "root"
  group "root"
  mode "0444"
  action :create
  content "staging"
end

file "/var/chef/environment" do
  only_if { node.chef_environment == "alpha" }
  owner "root"
  group "root"
  mode "0444"
  action :create
  content "alpha"
end

file "/var/chef/environment" do
  only_if { node.chef_environment == "production" }
  owner "root"
  group "root"
  mode "0444"
  action :create
  content "production"
end

service "chef-client" do
  action [ :enable, :start ]
end

template "/var/chef/role" do
  source "role.erb"
  owner "root"
  group "root"
  mode "0755"
  action :create
  variables(
    :role => node['roles'],
  )
end

bash "chef_run_touch" do
  user "root"
  cwd "/tmp"
  code <<-EOH
   touch /etc/chef/chef_run
   chown root:root /etc/chef/chef_run
  EOH
end


