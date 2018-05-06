#
# Cookbook Name:: test
# Recipe:: ulimit 
#
# 
#
# 
#

cookbook_file "/etc/security/limits.conf" do
  source "security/limits.conf"
  owner "root"
  group "root"
  mode "0644"
  action :create
end

