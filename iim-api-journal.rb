#
# Cookbook Name:: test
# Recipe:: iim-api-journal
#
# 
#
# 
#

yum_package "test-iim-api-journal" do 
    only_if { node.chef_environment == "development" }
    action :upgrade
    allow_downgrade true
end

yum_package "test-iim-api-journal" do 
    only_if { node.chef_environment == "staging" }
    version '18-58.amzn1'  
    action :install
    allow_downgrade true
end

yum_package "test-iim-api-journal" do 
    only_if { node.chef_environment == "production" }
    version '18-58.amzn1'  
    action :install
    allow_downgrade true
end

service "iim-api-journal" do
  action [ :enable, :start ]
end

