#
# Cookbook Name:: test
# Recipe:: nat
#
# 
#
# 
#

cookbook_file "/opt/tools/configure-pat.sh" do
  source "networking/configure-pat.sh"
  owner "root"
  group "root"
  mode "0755"
  action :create
end

file "/etc/cron.d/configure-pat" do
  manage_symlink_source true
  owner "root"
  group "root"
  mode "0644"
  action :create
  content "@reboot root /opt/tools/configure-pat.sh
  "
end


