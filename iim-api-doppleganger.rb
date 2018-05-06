#
# Cookbook Name:: test
# Recipe:: iim-api-doppleganger
#
# 
#
# 
#

yum_package "test-iim-api-doppleganger" do 
    only_if { node.chef_environment == "staging" || node.chef_environment == "development" }
    action :upgrade
    allow_downgrade true
end

service "iim-api-doppleganger" do
  only_if { node.chef_environment == "staging" || node.chef_environment == "development" }
  action [ :enable, :start ]
end

