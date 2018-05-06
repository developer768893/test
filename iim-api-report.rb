#
# Cookbook Name:: test
# Recipe:: iim-api-report
#
# 
#
# 
#

yum_package "test-iim-api-report" do 
    only_if { node.chef_environment == "development" }
    action :upgrade
    allow_downgrade true
end

yum_package "test-iim-api-report" do 
    only_if { node.chef_environment == "staging" }
    version '12-51.amzn1'  
    action :install
    allow_downgrade true
end

yum_package "test-iim-api-report" do 
    only_if { node.chef_environment == "production" }
    version '11-51.amzn1'  
    action :install
    allow_downgrade true
end

service "iim-api-report" do
  action [ :enable, :start ]
end

