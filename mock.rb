#
# Cookbook Name:: test
# Recipe:: Ad Server mock service
#
# 
#
# 
#

%w{python-setuptools java-1.8.0-openjdk-headless sed grep }.each do |pkg|
  yum_package pkg do
  action :install
 end
end

yum_package "test-rtb" do
  only_if { node.chef_environment == "production" }
    version '545-2062.amzn1'  
  action :install
  allow_downgrade true
end

yum_package "test-mock" do
  action :upgrade
  allow_downgrade true
end

service "dspmockservice" do
  action [ :disable, :stop ]
end

service "mock-plc1009293" do
  action [ :enable, :start ]
end

service "mock-plc1014497" do
  action [ :enable, :start ]
end

