#
# Cookbook Name:: test
# Recipe:: hosts
#
# 
#
# 
#

template "/etc/hosts" do
   source "ssh/hosts.erb"
   owner "root"
   group "root"
   mode "0644"
   action :create
   variables(
     :machinename => node['machinename']
   )
end

