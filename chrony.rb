#
# Cookbook Name:: test
# Recipe:: chrony
#
# 
#
# 
#

package "ntp" do
  action :remove
end

package "chrony" do
  action :install
end

service "chronyd" do
  action [ :enable, :start ]
end
