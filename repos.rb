#
# Cookbook Name:: test
# Recipe:: repos
#
# 
#
# 
#

cookbook_file "/etc/yum.conf" do
  source "repos/yum.conf"
  owner "root"
  group "root"
  mode "0644"
  action :create
end

cookbook_file "/etc/yum.repos.d/test.repo" do
  source "repos/test.repo"
  owner "root"
  group "root"
  mode "0644"
  action :create
end

cookbook_file "/etc/yum.repos.d/test-mirrorlist" do
  source "repos/test-mirrorlist"
  owner "root"
  group "root"
  mode "0644"
  action :create
end

cookbook_file "/etc/yum.repos.d/sensu.repo" do
  source "repos/sensu.repo"
  owner "root"
  group "root"
  action :create
end

bash "yum_clean_all" do
  user "root"
  cwd "/tmp"
  code <<-EOH
  yum clean all
  EOH
end

