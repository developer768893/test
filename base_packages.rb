#
# Cookbook Name:: test
# Recipe:: base_packages
#
# 
#
# 
#

%w{yum-plugin-fastestmirror nload htop initscripts python27-setuptools jq}.each do |pkg|
  package pkg do
  action :install
  end
end

