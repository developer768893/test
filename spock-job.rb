#
# Cookbook Name:: test
# Recipe:: spock-job 
#
# 
#
# 
#

%w{java-1.8.0-openjdk java-1.8.0-openjdk-devel test-supervisord }.each do |pkg|
  package pkg do
    action :install
  end
end

yum_package "test-etl3" do
    only_if { node.chef_environment == "development" }
    action :upgrade
    allow_downgrade true
end

yum_package "test-etl3" do
    only_if { node.chef_environment == "staging" }
version '726-1778.amzn1'  
    action :install
    allow_downgrade true
end

yum_package "test-etl3" do
    only_if { node.chef_environment == "production" }
version '726-1778.amzn1'  
    action :install
    allow_downgrade true
end

service "spock" do
  action [ :enable, :start ]
end

service "supervisord-spock" do
  action [ :enable, :start ]
end

