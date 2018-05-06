#
# Cookbook Name:: test
# Recipe:: rsui (Retail Sales UI)
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

yum_package "test-rsui" do only_if { node.chef_environment == "development" }
    action :upgrade
    allow_downgrade true
end

yum_package "test-rsui" do only_if { node.chef_environment == "staging" }
    version '8-39.amzn1'   
    action :install
    allow_downgrade true
end

yum_package "test-rsui" do only_if { node.chef_environment == "production" }
    version '8-39.amzn1'   
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

cookbook_file "/etc/httpd/conf.d/htpasswd" do
  source "apache/htpasswd.rsui"
  owner "root"
  group "root"
  mode "0644"
  action :create
end

cookbook_file "/etc/httpd/conf.d/rsui.conf" do
  source "apache/rsui.conf"
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

