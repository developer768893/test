#
# Cookbook Name:: test
# Recipe:: aws-tools for ad server events hosts
#
# 
#
# 
#

package "test-aws-tools" do
   only_if { node.chef_environment == "development" || node.chef_environment == "staging" }
   action :remove
end

package "test-aws-tools" do
   only_if { node.chef_environment == "alpha" || node.chef_environment == "production" }
   action :upgrade
end

cookbook_file "/opt/aws-tools/etc/aws-tools-config" do
  only_if { node.chef_environment == "alpha" }
  source "ad/aws-tools-config-alpha"
  owner "root"
  group "root"
  mode "0644"
  action :create
  notifies :restart, "service[aws-tools]", :delayed
end

cookbook_file "/opt/aws-tools/etc/aws-tools-config-agn" do
  only_if { node.chef_environment == "alpha" }
  source "ad/aws-tools-config-agn-alpha"
  owner "root"
  group "root"
  mode "0644"
  action :create
  notifies :restart, "service[aws-tools]", :delayed
end

cookbook_file "/opt/aws-tools/etc/aws-tools-config" do
  only_if { node.chef_environment == "production" }
  notifies :restart, "service[aws-tools]", :delayed
  source "ad/aws-tools-config-prod"
  owner "root"
  group "root"
  mode "0644"
  action :create
  notifies :restart, "service[aws-tools]", :delayed
end

cookbook_file "/opt/aws-tools/etc/aws-tools-config-agn" do
  only_if { node.chef_environment == "production" }
  notifies :restart, "service[aws-tools]", :delayed
  source "ad/aws-tools-config-agn-prod"
  owner "root"
  group "root"
  mode "0644"
  action :create
  notifies :restart, "service[aws-tools]", :delayed
end

service "aws-tools" do
  only_if { node.chef_environment == "alpha" || node.chef_environment == "production" }
  action [ :enable, :start ]
end

