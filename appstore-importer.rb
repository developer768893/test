#
# Cookbook Name:: test
# Recipe:: Ad Server AppStore Importer
#
# 
#
# 
#

%w{java-1.8.0-openjdk-headless }.each do |pkg|
  yum_package pkg do
  action :install
 end
end

yum_package "test-appstore-importer" do
  action :upgrade
  allow_downgrade true
end

service "appstore-importer" do
  action [ :enable, :start ]
end

