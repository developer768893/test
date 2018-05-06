#
# Cookbook Name:: test
# Recipe:: Ad Server TestLink
#
# 
#
# 
#

%w{java-1.8.0-openjdk }.each do |pkg|
  package pkg do
    action :install
  end
end

yum_package "test-testlink" do
    only_if { node.chef_environment == "development" }
    action :upgrade
    allow_downgrade true
end

yum_package "test-testlink" do
    only_if { node.chef_environment == "staging" } 
version '1269-10621.amzn1'  
    action :install
    allow_downgrade true
end

yum_package "test-testlink" do
    only_if { node.chef_environment == "production" } 
version '1265-10608.amzn1'  
    action :install
    allow_downgrade true
end

service "testlink" do
  action [ :enable, :start ]
end

