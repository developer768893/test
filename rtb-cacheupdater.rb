#
# Cookbook Name:: test
# Recipe:: rtb-cacheupdater
#
# 
#
# 
#

%w{java-1.7.0-openjdk}.each do |pkg|
  package pkg do
    action :remove
  end
end

%w{java-1.8.0-openjdk}.each do |pkg|
  package pkg do
    action :install
  end
end

yum_package "test-rtb" do
    only_if { node.chef_environment == "development" }
    action :upgrade
    allow_downgrade true
    notifies :restart, "service[endpointconfigurationfetchjob]", :delayed
end

yum_package "test-rtb" do
    only_if { node.chef_environment == "staging" }
    version '549-2076.amzn1'  
    action :install
    allow_downgrade true
    notifies :restart, "service[endpointconfigurationfetchjob]", :delayed
end

yum_package "test-rtb" do
    only_if { node.chef_environment == "production" }
    version '545-2062.amzn1'  
    action :install
    allow_downgrade true
    notifies :restart, "service[endpointconfigurationfetchjob]", :delayed
end

yum_package "test-rtb" do
    only_if { node.chef_environment == "alpha" }
    version '547-2074.amzn1'  
    action :install
    allow_downgrade true
    notifies :restart, "service[endpointconfigurationfetchjob]", :delayed
end

service "endpointconfigurationfetchjob" do
  action [ :enable, :start ]
end

