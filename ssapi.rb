#
# Cookbook Name:: test
# Recipe:: ssapi
#
# 
#
# 
#

%w{httpd24 mod24_ssl python-setuptools java-1.8.0-openjdk }.each do |pkg|
  package pkg do
    action :install
  end
end

yum_package "java-1.7.0-openjdk" do
    action :remove
end

yum_package "test-jetty-9" do
    action :upgrade
    allow_downgrade true
end

yum_package "test-ssapi" do
    only_if { node.chef_environment == "development" }
    action :upgrade
    allow_downgrade true
end

yum_package "test-ssapi" do
    only_if { node.chef_environment == "staging" }
version '122-363.amzn1'  
    action :install
    allow_downgrade true
end

yum_package "test-ssapi" do
    only_if { node.chef_environment == "production" }
version '122-363.amzn1'  
    action :install
    allow_downgrade true
end

cookbook_file "/etc/pki/tls/certs/dhparams.pem" do
  source "apache/dhparams.pem"
  owner "root"
  group "root"
  mode "0400"
  action :create
  notifies :restart, "service[httpd]", :delayed
end

cookbook_file "/etc/pki/tls/certs/test.crt" do
  source "apache/test.crt"
  owner "root"
  group "root"
  mode "0400"
  action :create
  notifies :restart, "service[httpd]", :delayed
end

cookbook_file "/etc/pki/tls/private/test.key" do
  source "apache/test.key"
  owner "root"
  group "root"
  mode "0400"
  action :create
  notifies :restart, "service[httpd]", :delayed
end

cookbook_file "/etc/httpd/conf.d/ssapi.conf" do
  source "apache/ssapi.conf"
  owner "root"
  group "root"
  mode "0400"
  action :create
  notifies :restart, "service[httpd]", :delayed
end

file "/etc/httpd/conf.d/ssl.conf" do
  action :delete
  notifies :restart, "service[httpd]", :delayed
end

service "httpd" do
  action [ :enable, :start ]
end

service "jetty" do
  action [ :enable, :start ]
end

