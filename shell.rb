#
# Cookbook Name:: test
# Recipe:: shell
#
# 
#
# 
#

cookbook_file "/etc/profile.d/ps1.sh" do
  source "bash-profiles/ps1.sh"
  owner "root"
  group "root"
  mode "0644"
  action :create
end

cookbook_file "/root/.bash_profile" do
  owner "root"
  group "root"
  mode "0600"
  action :create
  source "bash-profiles/bash_profile"
end

