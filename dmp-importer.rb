#
# Cookbook Name:: test
# Recipe:: DMP importer
#
# 
#
# 
#

%w{java-1.8.0-openjdk}.each do |pkg|
  package pkg do
    action :install
  end
end

user 'dmp' do
  comment 'dmp system user for ad server'
  system true
  shell '/bin/false'
end

yum_package "test-dmp" do 
    only_if { node.chef_environment == "development" }
    action :upgrade
    allow_downgrade true
end

yum_package "test-dmp" do
    only_if { node.chef_environment == "staging" }
version '1269-10621.amzn1'  
    action :install
    allow_downgrade true
end

yum_package "test-dmp" do
    only_if { node.chef_environment == "production" }
version '1265-10608.amzn1'  
    action :install
    allow_downgrade true
end

#dmp importer
service "dmp-importer" do
  action [ :enable, :start ]
end

